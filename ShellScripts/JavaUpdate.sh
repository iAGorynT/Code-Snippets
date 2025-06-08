#!/bin/zsh
# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { echo "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Function to display script header
display_header() {
    local header="Java Update..."
    [[ "$1" == "--no-clear" ]] || clear
    format_printf "$header" "yellow" "bold"
}

# Function to get yes/no input
get_yes_no() {
    local prompt="$1" response

    while true; do
        read "response?$prompt (y/n): "
        case ${response:l} in
            y|yes) return 0 ;;
            n|no)  return 1 ;;
            *) echo "Please answer yes (Y) or no (N)." ;;
        esac
    done
}

# Enhanced architecture detection
detect_architecture() {
    local arch=$(uname -m)
    local arch_str arch_human
    
    case "$arch" in
        arm64|aarch64)
            arch_str="macosx_aarch64"
            arch_human="Apple Silicon (M1/M2/M3/M4)"
            ;;
        x86_64|amd64)
            arch_str="macosx_x64"
            arch_human="Intel x64"
            ;;
        *)
            error_printf "Unsupported architecture: $arch"
            return 1
            ;;
    esac
    
    printf "%s|%s" "$arch_str" "$arch_human"
}

# Find appropriate DMG for architecture
find_architecture_dmg() {
    local latest_version="$1"
    local arch_str="$2"
    local dmg_url=""
    
    # More specific pattern matching
    for link in "${sorted[@]}"; do
        if [[ "$link" =~ zulu${latest_version//./\\.}-ca-jdk[0-9.]+-${arch_str}\.dmg$ ]]; then
            dmg_url="https://cdn.azul.com/zulu/bin/$link"
            break
        fi
    done
    
    printf "%s" "$dmg_url"
}

# Enhanced download function with progress and error handling
download_java_dmg() {
    local dmg_url="$1"
    local download_dir="$HOME/Downloads"
    local download_path="$download_dir/$(basename "$dmg_url")"
    
    # Validate inputs
    [[ -n "$dmg_url" ]] || { error_printf "No download URL provided"; return 1; }
    
    # Ensure Downloads directory exists
    if [[ ! -d "$download_dir" ]]; then
        warning_printf "Downloads directory not found: $download_dir"
        if get_yes_no "Create Downloads directory?"; then
            mkdir -p "$download_dir" || {
                error_printf "Failed to create Downloads directory"
                return 1
            }
            success_printf "Created Downloads directory"
        else
            return 1
        fi
    fi
    
    # Get expected file size for validation
    info_printf "Checking file information..."
    local expected_size=$(curl -sI --connect-timeout 10 "$dmg_url" | grep -i content-length | awk '{print $2}' | tr -d '\r' 2>/dev/null)
    if [[ -n "$expected_size" && "$expected_size" -gt 0 ]]; then
        local size_human=$(numfmt --to=iec "$expected_size" 2>/dev/null || echo "$expected_size bytes")
        info_printf "Expected download size: $size_human"
    fi
    
    # Handle existing files
    if [[ -f "$download_path" ]]; then
        local existing_size=$(stat -f%z "$download_path" 2>/dev/null || echo 0)
        warning_printf "File already exists: $(basename "$download_path") ($(numfmt --to=iec "$existing_size" 2>/dev/null || echo "$existing_size bytes"))"
        
        if get_yes_no "Overwrite existing file?"; then
            rm "$download_path"
        else
            # Create unique filename with timestamp
            local timestamp=$(date +"%Y%m%d_%H%M%S")
            local base_name=$(basename "$dmg_url" .dmg)
            download_path="$download_dir/${base_name}_${timestamp}.dmg"
            info_printf "Using alternate filename: $(basename "$download_path")"
        fi
    fi
    
    # Download with progress indicator and better error handling
    info_printf "Downloading: $(basename "$download_path")"
    printf "Progress: "
    
    # Use curl with progress bar and comprehensive error handling
    if curl -L \
        --fail \
        --show-error \
        --connect-timeout 30 \
        --max-time 3600 \
        --retry 3 \
        --retry-delay 5 \
        --progress-bar \
        "$dmg_url" \
        -o "$download_path" 2>&1; then
        
        printf "\n"
        
        # Verify download integrity
        if [[ -s "$download_path" ]]; then
            local actual_size=$(stat -f%z "$download_path" 2>/dev/null || wc -c < "$download_path")
            local size_human=$(numfmt --to=iec "$actual_size" 2>/dev/null || echo "$actual_size bytes")
            
            success_printf "Download completed successfully!"
            info_printf "Downloaded file: $download_path"
            info_printf "File size: $size_human"
            
            # Validate file size if we got expected size
            if [[ -n "$expected_size" && "$expected_size" -gt 0 ]]; then
                if [[ "$actual_size" -eq "$expected_size" ]]; then
                    success_printf "File size validation: PASSED"
                else
                    warning_printf "File size mismatch - Expected: $(numfmt --to=iec "$expected_size"), Got: $size_human"
                    warning_printf "Download may be incomplete or corrupted"
                fi
            fi
            
            # Optional actions
            printf "\n"
            if get_yes_no "Open Downloads folder in Finder?"; then
                open "$download_dir"
            fi
            
            return 0
        else
            error_printf "Downloaded file appears to be empty or corrupted"
            rm -f "$download_path"
            return 1
        fi
    else
        printf "\n"
        local curl_exit_code=$?
        error_printf "Download failed (exit code: $curl_exit_code)"
        
        # Provide specific error messages based on curl exit codes
        case $curl_exit_code in
            6)  error_printf "Could not resolve host - check your internet connection" ;;
            7)  error_printf "Failed to connect to server" ;;
            22) error_printf "HTTP error - file may not exist on server" ;;
            28) error_printf "Download timeout - file may be too large or connection too slow" ;;
            *)  error_printf "Network error occurred during download" ;;
        esac
        
        # Clean up partial download
        [[ -f "$download_path" ]] && rm -f "$download_path"
        return 1
    fi
}

# Function to show available architectures when none found
show_available_architectures() {
    local latest_version="$1"
    info_printf "Available architectures for version $latest_version:"
    
    local found_archs=()
    for link in "${sorted[@]}"; do
        if [[ "$link" =~ zulu${latest_version//./\\.}-ca.*\.dmg$ ]]; then
            # Extract architecture from filename
            local arch_from_link=$(echo "$link" | grep -oE 'macosx_[^.]+' | head -1)
            if [[ -n "$arch_from_link" ]]; then
                found_archs+=("$arch_from_link")
            fi
        fi
    done
    
    # Remove duplicates and display
    local unique_archs=(${(u)found_archs[@]})
    for arch in "${unique_archs[@]}"; do
        printf "  - %s\n" "$arch"
    done
}

# --- Main script execution ---
display_header "$1"

# Ask if user wants to run Java Update
if get_yes_no "$(format_printf "Do you want to run Java Update?" none "rocket")"; then
    printf "\n"
    
    # Get current installed Java version (Zulu style)
    # Handle both formats: Zulu24.30.11 and Zulu24.30+11-CA
    java_version_output=$(java -version 2>&1)
    if echo "$java_version_output" | grep -q "Zulu"; then
        # Extract the Zulu version pattern and clean it up
        current_zulu_version=$(echo "$java_version_output" | grep -oE 'Zulu[0-9]+\.[0-9]+[+\.][0-9]+' | head -1 | sed -E 's/Zulu([0-9]+\.[0-9]+)[+\.]([0-9]+).*/\1.\2/')
    else
        current_zulu_version=""
    fi
    
    # Check if we found a Zulu version
    if [[ -z "$current_zulu_version" ]]; then
        warning_printf "Current installed Zulu version: Not found (or not Zulu JDK)"
    else
        info_printf "Current installed Zulu version: $current_zulu_version"
    fi
    
    update_printf "Checking for latest version..."
    
    # Fetch list of all Zulu .dmg files from CDN with timeout
    file_list=$(curl -s --connect-timeout 15 --max-time 30 https://cdn.azul.com/zulu/bin/)
    
    # Check if curl was successful
    if [[ $? -ne 0 || -z "$file_list" ]]; then
        error_printf "Failed to fetch version information from Azul CDN" true
    fi
    
    # Extract macOS .dmg filenames with Zulu and Java 11+
    dmg_links=(${(@f)$(grep -Eo 'zulu([0-9]+\.[0-9]+\.[0-9]+)-ca-jdk(1[1-9]|2[0-9])[0-9\.\-]*-macosx_[^"]+\.dmg' <<< "$file_list")})
    
    # Remove duplicate links and sort (reverse natural sort)
    unique_dmg_links=(${(u)dmg_links[@]})
    sorted=(${(On)unique_dmg_links[@]})
    
    # Extract latest Zulu version
    latest_zulu_version=""
    for link in "${sorted[@]}"; do
        if [[ "$link" =~ zulu([0-9]+\.[0-9]+\.[0-9]+)-ca ]]; then
            latest_zulu_version="${match[1]}"
            break
        fi
    done
    
    if [[ -z "$latest_zulu_version" ]]; then
        error_printf "Could not determine latest Zulu version" true
    fi
    
    # Now list all links that match this latest version
    printf "\n"
    success_printf "Latest Zulu version: $latest_zulu_version"
    package_printf "macOS .dmg links for this version:"
    for link in "${sorted[@]}"; do
        if [[ "$link" =~ zulu([0-9]+\.[0-9]+\.[0-9]+)-ca ]]; then
            version="${match[1]}"
            if [[ "$version" == "$latest_zulu_version" ]]; then
                printf "  https://cdn.azul.com/zulu/bin/%s\n" "$link"
            fi
        fi
    done
    printf "\n"
    
    # Function to compare semver-style Zulu versions
    ver_gt() {
        autoload -Uz is-at-least
        ! is-at-least "$1" "$2"
    }
    
    # Compare and output result only if we have a current version
    if [[ -n "$current_zulu_version" ]]; then
        if ver_gt "$latest_zulu_version" "$current_zulu_version"; then
            upgrade_printf "A newer Zulu version is available: $latest_zulu_version"
            printf "   Your current version: %s\n" "$current_zulu_version"
            printf "\n"
            
            # Ask if user wants to download the DMG with improved functionality
            if get_yes_no "Would you like to download the installer .dmg file for the latest version?"; then
                # Detect architecture with better error handling
                arch_info=$(detect_architecture) || {
                    error_printf "Could not detect system architecture" true
                }
                IFS='|' read -r arch_str arch_human <<< "$arch_info"
                
                info_printf "Detected Mac architecture: $arch_human"
                
                # Find appropriate DMG with improved matching
                dmg_url=$(find_architecture_dmg "$latest_zulu_version" "$arch_str")
                
                if [[ -n "$dmg_url" ]]; then
                    printf "\n"
                    info_printf "Found installer: $(basename "$dmg_url")"
                    download_java_dmg "$dmg_url"
                else
                    error_printf "Could not find a .dmg file for your architecture ($arch_str)"
                    printf "\n"
                    show_available_architectures "$latest_zulu_version"
                fi
            fi
        else
            success_printf "You're already using the latest or a newer Zulu version."
            printf "   Your current version: %s\n" "$current_zulu_version"
        fi
    else
        warning_printf "Cannot compare versions - Zulu JDK not detected in your current Java installation"
        printf "   Latest available version: %s\n" "$latest_zulu_version"
        
        # Still offer download even if no current version detected
        printf "\n"
        if get_yes_no "Would you like to download the latest Zulu JDK installer anyway?"; then
            arch_info=$(detect_architecture) || {
                error_printf "Could not detect system architecture"
                exit 1
            }
            IFS='|' read -r arch_str arch_human <<< "$arch_info"
            
            info_printf "Detected Mac architecture: $arch_human"
            dmg_url=$(find_architecture_dmg "$latest_zulu_version" "$arch_str")
            
            if [[ -n "$dmg_url" ]]; then
                printf "\n"
                info_printf "Found installer: $(basename "$dmg_url")"
                download_java_dmg "$dmg_url"
            else
                error_printf "Could not find a .dmg file for your architecture ($arch_str)"
                printf "\n"
                show_available_architectures "$latest_zulu_version"
            fi
        fi
    fi
else
    error_printf "Java Update cancelled by user."
fi

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
    # Fetch list of all Zulu .dmg files from CDN
    file_list=$(curl -s https://cdn.azul.com/zulu/bin/)
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
        else
            success_printf "You're already using the latest or a newer Zulu version."
            printf "   Your current version: %s\n" "$current_zulu_version"
        fi
    else
        warning_printf "Cannot compare versions - Zulu JDK not detected in your current Java installation"
        printf "   Latest available version: %s\n" "$latest_zulu_version"
    fi
else
    error_printf "Java Update cancelled by user."
fi

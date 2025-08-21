#!/bin/zsh
# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Function to display script header
display_header() {
    clear
    package_printf "Python Uninstaller..."
    printf "\n"
}

# Get yes/no input
get_yes_no() {
    local prompt="$1"
    local response
    while true; do
        read "response?$prompt (y/n): "
        case ${response:l} in
            y|yes) return 0 ;;
            n|no)  return 1 ;;
            *) echo "Please answer yes (Y) or no (N)." ;;
        esac
    done
}

# Function to get installed Python versions
get_installed_versions() {
    local versions=()
    
    # Try pyenv versions command first
    if command -v pyenv >/dev/null 2>&1; then
        # Get versions from pyenv versions command, filter out system and current indicators
        while IFS= read -r line; do
            # Remove leading/trailing whitespace and special characters (* and ->)
            version=$(echo "$line" | sed 's/^[[:space:]]*\*[[:space:]]*//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | cut -d' ' -f1)
            # Only include versions that match X.X.X pattern (exclude 'system' and other non-version entries)
            if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
                versions+=("$version")
            fi
        done < <(pyenv versions --bare 2>/dev/null)
    fi
    
    # If pyenv command failed or returned no versions, check the versions directory
    if [[ ${#versions[@]} -eq 0 ]] && [[ -d "$HOME/.pyenv/versions" ]]; then
        while IFS= read -r dir; do
            local basename=$(basename "$dir")
            # Only include directories that match X.X.X pattern
            if [[ "$basename" =~ ^[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
                versions+=("$basename")
            fi
        done < <(find "$HOME/.pyenv/versions" -maxdepth 1 -type d 2>/dev/null | tail -n +2)
    fi
    
    # Sort versions and return
    printf '%s\n' "${versions[@]}" | sort -V
}

# Function to display menu and get user choice
display_menu() {
    local versions=("$@")
    local choice
    
    if [[ ${#versions[@]} -eq 0 ]]; then
        error_printf "No Python versions found installed via pyenv."
        return 1
    fi
    
    info_printf "Installed Python Versions:"
    
    # Display numbered menu
    for i in {1..${#versions[@]}}; do
        printf "%2d) %s\n" "$i" "${versions[$i]}"
    done
    
    printf "%2d) Exit\n" $((${#versions[@]} + 1))
    printf "\n"
    
    while true; do
        read "choice?Select option (1-$((${#versions[@]} + 1))): "

	# Default to exit if no input
        if [[ -z "$choice" ]]; then
            choice=$((${#versions[@]} + 1))
        fi
        
        # Check if input is a number
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [[ "$choice" -ge 1 && "$choice" -le ${#versions[@]} ]]; then
                return $((choice - 1))  # Return 0-based index
            elif [[ "$choice" -eq $((${#versions[@]} + 1)) ]]; then
                return 255  # Special return code for exit
            fi
        fi
        
        error_printf "Invalid selection. Please choose 1-$((${#versions[@]} + 1))."
    done
}

# Function to uninstall Python version
uninstall_python() {
    local version="$1"
    
    update_printf "Uninstalling Python $version..."
    
    if pyenv uninstall "$version"; then
        success_printf "Successfully uninstalled Python $version"
    else
        error_printf "Failed to uninstall Python $version"
    fi
}

# Main function
main() {
    # Check if pyenv is installed
    if ! command -v pyenv >/dev/null 2>&1; then
        error_printf "Error: pyenv is not installed or not in PATH"
        exit 1
    fi
    
    while true; do
        display_header
        
        # Get installed versions
        local versions_array=()
        while IFS= read -r version; do
            [[ -n "$version" ]] && versions_array+=("$version")
        done < <(get_installed_versions)
        
        # Display menu and get user choice
        display_menu "${versions_array[@]}"
        local menu_choice=$?
        
        # Handle exit choice
        if [[ $menu_choice -eq 255 ]]; then
            printf "\n"
            success_printf "Python Uninstaller completed..."
            break
        fi
        
        # Handle no versions found
        if [[ $menu_choice -eq 1 ]] && [[ ${#versions_array[@]} -eq 0 ]]; then
            printf "Press Enter to continue..."
            read
            continue
        fi
        
        # Get selected version (zsh arrays are 1-indexed, menu_choice is 0-based)
        local selected_version="${versions_array[$((menu_choice + 1))]}"
        printf "\n"

        # Confirm uninstall
        if get_yes_no "Are you sure you want to uninstall Python ${selected_version}?"; then
            printf "\n"
            uninstall_python "$selected_version"
        else
            warning_printf "Uninstall cancelled."
        fi
        
        printf "\nPress Enter to continue..."
        read
    done
}

# Run the main function
main "$@"

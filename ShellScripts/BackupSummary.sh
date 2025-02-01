#!/bin/zsh
# Enable error handling
setopt ERR_EXIT
setopt PIPE_FAIL

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatEcho.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    echo "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

# Function to check if directory exists
function check_directory {
    local dir=$1
    if [[ ! -d "$dir" ]]; then
        error_echo "Error: Directory '$dir' not found" true >&2
    fi
}

# Function to print section header
function print_header {
    local text=$1
    echo
    info_echo "$text" 
    echo "Filename | Modified Date | Size"
    echo "-------------------------------------"
}

# Function to search files
function search_files {
    local dir=$1
    local pattern=$2
    local maxdepth=${3:-1}  # Optional parameter, defaults to 1
    # Declare local variable outside loop to avoid subshell scoping issues
    local size
    
    if ! check_directory "$dir"; then
        return 1
    fi
    
    # Use process substitution to capture and sort the output
    find "$dir" -maxdepth $maxdepth -name "$pattern" -type f -print0 | \
    while IFS= read -r -d '' file; do
        size=$(du -h "$file" | cut -f1)
        printf "%s|%s|%s\n" \
            "$(basename "$file")" \
            "$(date -r "$file" "+%Y-%m-%d %H:%M:%S")" \
            "$size"
    done | sort -t'|' -k1,1 | sed 's/|/ | /g' || error_echo "Error searching in $dir" >&2
}

# Function to eject thumb drive
function eject_drive {
    local which_drive=$1

    # Run diskutil eject and capture its output
    local eject_output=$(diskutil eject "$which_drive" 2>&1)
    
    # Only display output if it's not empty
    if [[ -n "$eject_output" ]]; then
        info_echo "$eject_output"
    fi
}

# Main script
function main {
    local downloads_path="$HOME/Downloads/zVault Backup"
    local private_path="/Volumes/Private"
    local shortcuts_downloads="$downloads_path/Shortcuts Config Files"
    local shortcuts_private="$private_path/Shortcuts Config Files"
    local brukasa_disk=false
    
    # Determine if BruKasa Thumb Drive is connected
    if diskutil list external | grep -q 'Private'; then
        brukasa_disk=true
    fi
    
    # Print Title
    clear
    format_echo "Backup Summary..." yellow bold
    
    # Search for encrypted files
    print_header "Encrypted Files (.enc) in ~/Downloads/zVault Backup"
    search_files "$downloads_path" "*.enc"
    
    if [[ "$brukasa_disk" == "true" ]]; then
        print_header "Encrypted Files (.enc) in /Volumes/Private"
        search_files "$private_path" "*.enc"
    fi
    
    # Search for JSON files
    print_header "JSON Files in ~/Downloads/zVault Backup/Shortcuts Config Files"
    search_files "$shortcuts_downloads" "*.json"
    
    if [[ "$brukasa_disk" == "true" ]]; then
        print_header "JSON Files in /Volumes/Private/Shortcuts Config Files"
        search_files "$shortcuts_private" "*.json"
    fi	

    # Ask to Eject Brukasa Thumb Drive
    if [[ "$brukasa_disk" == "true" ]]; then
        echo
        while true; do
            read yn\?"Eject Private Thumb Drive (Y/N): "
            case $yn in
                [Yy]* ) eject_drive "$private_path"; break;;
                [Nn]* ) break;;
                * ) echo "Please answer yes (Y) or no (N).";;
            esac
        done
    fi
}

# Run main function
main "$@"


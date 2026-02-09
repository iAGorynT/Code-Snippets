#!/bin/zsh

# Zsh script to remove contents from specific folders in opencode_workspace
# This script will preserve the folder structure but remove all files within:
# - backups/
# - new/
# - scripts/

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

WORKSPACE_DIR="$HOME/Desktop/opencode_workspace"
TARGET_DIRS=("backups" "new" "scripts")

info_printf "Starting cleanup of folder contents in opencode_workspace..."

# Function to display script header
display_header() {
    clear
    format_printf "Cleanup Opencode Workspace..." "yellow" "bold"
    printf "\n"
}

# Function to prompt for confirmation
confirm_deletion() {
    warning_printf "This will remove contents from the following directories:"
    for dir_name in "${TARGET_DIRS[@]}"; do
        local folder="$WORKSPACE_DIR/$dir_name"
        if [ -d "$folder" ]; then
            format_printf "  • $dir_name/" "blue" "bold"
            if [ -n "$(find "$folder" -mindepth 1 2>/dev/null)" ]; then
                format_printf "    Contains files that will be deleted" "red"
            else
                format_printf "    Already empty" "green"
            fi
        else
            format_printf "  • $dir_name/" "gray" "bold"
            format_printf "    Directory does not exist" "gray"
        fi
    done
    
    printf "\n"
    error_printf "WARNING: This action cannot be undone!"
    # Use direct printf with color formatting to keep input on same line
    printf '\033[1;33m%s\033[0m' "Do you want to continue? (y/N): "
    
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS])
            return 0
            ;;
        *)
            error_printf "Claude Cleanup cancelled by user."
            exit 0
            ;;
    esac
}

# Function to clear contents of a directory
clear_directory_contents() {
    local dir="$1"
    if [ -d "$dir" ]; then
        info_printf "Clearing contents of: $dir"
        # Remove all files and subdirectories within the directory
        find "$dir" -mindepth 1 -delete 2>/dev/null
        if [ $? -eq 0 ]; then
            success_printf "Cleared: $dir"
        else
            error_printf "Failed to clear: $dir"
        fi
    fi
}

# Check if workspace directory exists
if [ ! -d "$WORKSPACE_DIR" ]; then
    error_printf "opencode_workspace directory not found at $WORKSPACE_DIR" true
fi

# Display the header
display_header

# Prompt for confirmation before proceeding
confirm_deletion

# Process only the target directories
for dir_name in "${TARGET_DIRS[@]}"; do
    local folder="$WORKSPACE_DIR/$dir_name"
    if [ -d "$folder" ]; then
        clear_directory_contents "$folder"
    else
        info_printf "Directory does not exist, skipping: $dir_name"
    fi
done

success_printf "Selective cleanup of backups, new, and scripts directories completed!"

# Show the current structure
printf "\n"
info_printf "Current folder structure:"
tree "$WORKSPACE_DIR" 2>/dev/null || find "$WORKSPACE_DIR" -type d | sed 's|[^/]*/|  |g'


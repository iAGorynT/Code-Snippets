#!/bin/zsh
# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { error_printf "Required library $FORMAT_LIBRARY not found" true; }
source "$FORMAT_LIBRARY"

# Directory variables
WORKSPACE_DIR="$HOME/Desktop/claude_workspace/scripts"
BIN_DIR="$HOME/bin"
CHANGES_LOG="changes.log"

# Function to display script header
display_header() {
    clear
    format_printf "Replace Shellscript Text..." "yellow" "bold"
}

# Function to get yes/no input
get_yes_no() {
    local prompt="$1" response
    
    while true; do
        read "response?$prompt (y/n): "
        case ${response:l} in
            y|yes) return 0 ;;
            n|no)  return 1 ;;
            *) format_printf "Please answer yes (Y) or no (N)." "yellow" "warning" ;;
        esac
    done
}

# Function to get user input for text replacement
get_replacement_text() {
    local old_text new_text
    
    format_printf "Enter the text you want to replace:" "cyan" "bold"
    read "old_text?> "
    
    if [[ -z "$old_text" ]]; then
        error_printf "No text entered. Exiting." true
    fi
    
    format_printf "Enter the new replacement text:" "cyan" "bold"
    read "new_text?> "
    
    if [[ -z "$new_text" ]]; then
        error_printf "No replacement text entered. Exiting." true
    fi
    
    # Return values through global variables
    TEXT_TO_REPLACE="$old_text"
    REPLACEMENT_TEXT="$new_text"
}

# --- Main script execution ---
display_header

# Ask user if they want to run the script
if ! get_yes_no "$(format_printf "Do you want to run Replace Shellscript Text?" none "rocket")"; then
    error_printf "Script cancelled by user."
    exit 0
fi

# Get replacement text from user
get_replacement_text

# Go to target directory
cd "$WORKSPACE_DIR" || { error_printf "Cannot change to directory: $WORKSPACE_DIR" true; }

printf "\n"
info_printf "Searching for files containing: '$TEXT_TO_REPLACE'"

# Find files with the text and log them
grep -rl "$TEXT_TO_REPLACE" --include='*.sh' . > "$CHANGES_LOG"

# Apply the changes
if [[ -s "$CHANGES_LOG" ]]; then
    format_printf "Files found containing '$TEXT_TO_REPLACE':" "green" "bold"
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        info_printf "Found: $file"
    done < "$CHANGES_LOG"
    
    format_printf "Applying changes..." "yellow" "bold" "update"
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        update_printf "Updating $file"
        sed -i.bak "s/$TEXT_TO_REPLACE/$REPLACEMENT_TEXT/g" "$file"
    done < "$CHANGES_LOG"
    
    success_printf "Text replacement completed successfully!"
else
    warning_printf "No files found containing '$TEXT_TO_REPLACE'"
    exit 0
fi

# Check if changes.log exists
if [[ ! -f "$CHANGES_LOG" ]]; then
    error_printf "Changes log not found in current directory" true
fi

# Ask user if they want to copy updated files
printf "\n"
if ! get_yes_no "Do you want to copy the updated files to $BIN_DIR?"; then
    info_printf "Copy operation skipped by user."
    exit 0
fi

# Create bin directory if it doesn't exist
if [[ ! -d "$BIN_DIR" ]]; then
    info_printf "Creating directory: $BIN_DIR"
    mkdir -p "$BIN_DIR"
fi

# Copy updated files
format_printf "Copying updated files to $BIN_DIR..." "cyan" "bold" "package"
while IFS= read -r filename; do
    [[ -z "$filename" ]] && continue
    
    if [[ -f "$filename" ]]; then
        package_printf "Copying: $filename"
        cp "$filename" "$BIN_DIR"
    else
        warning_printf "File not found: $filename"
    fi
done < "$CHANGES_LOG"

success_printf "Copy operation completed successfully!"

#!/bin/zsh

# Source function library with error handling

SCRIPT_DIR="${0:a:h}"
FORMAT_LIBRARY="$SCRIPT_DIR/FLibFormatPrintf.sh"

if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    printf "Error: Required library not found: %s\n" "$FORMAT_LIBRARY" >&2
    printf "Searched in script directory: %s\n" "$SCRIPT_DIR" >&2
    exit 1
fi

source "$FORMAT_LIBRARY"

# Function to display script header
display_header() {
    clear
    format_printf "Disk Cleanup..." yellow bold
    printf "\n"
}

# Function to delete a file or directory
delete_item() {
  local target="$1"
  if [ -f "$target" ] || [ -d "$target" ]; then
    info_printf "Deleting: $target"
    rm -rv "$target"
  else
    info_printf "Nothing to delete: '$target' does not exist or is not a file/directory."
  fi
}

# Get yes/no input
get_yes_no() {
    local prompt="$1"
    local response
    while true; do
        read -k 1 "response?$prompt (y/n): "
        printf '\n' 
        case ${response:l} in
            y) return 0 ;;
            n) return 1 ;;
            *) error_printf "Please answer yes (Y) or no (N)." ;;
        esac
    done
}

# Main script execution
main() {
    # Display header
    display_header

    # Ask if user wants to run disk cleanup
    if get_yes_no "$(format_printf "Do you want to run Disk Cleanup?" none "rocket")"; then
        printf "\n"
	# Delete Vim Plugin Update Log
	delete_item $HOME/.logs/vim_plugin_update.log
    else
        error_printf "Disk Cleanup cancelled by user."
    fi
}

# Run the script
main

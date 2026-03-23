#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
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
        printf '\n'  # <-- newline using printf
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

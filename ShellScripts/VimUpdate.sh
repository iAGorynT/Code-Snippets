#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    echo "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

# Function to display script header
display_header() {
    clear
    format_printf "Vim Plugin Update..." "yellow" "bold"
}

# Function to update pip packages
update_vim_plugins() {
    local LOG_FILE="$HOME/.logs/vim_plugin_update.log"
    echo | tee -a "$LOG_FILE"
    package_printf "Starting vim plugin update..." | tee -a "$LOG_FILE"
    time_printf "Timestamp: $(date)" | tee -a "$LOG_FILE"
    
    # Check for vim
    if ! command -v mvim >/dev/null; then
        error_printf "vim is not installed or not in PATH." | tee -a "$LOG_FILE"
        return 1
    fi
    
    # Update vim plugins
    mvim -c 'PlugUpgrade | PlugUpdate | redir >> ~/.logs/vim_plugin_update.log | redir END | qa!'
    if [[ $? -eq 0 ]]; then
        success_printf "Vim plugin update completed successfully." | tee -a "$LOG_FILE"
    else
        error_printf "Vim plugin update failed." | tee -a "$LOG_FILE"
        return 1
    fi
    
    return 0
}

# Helper: View log file
view_log() {
    if [[ ! -f "$1" ]]; then
        error_printf "Log file not found: $1"
        return 1
    fi
    
    if [[ ! -s "$1" ]]; then
        info_printf "Log file is empty: $1"
        return 0
    fi
    
    clear
    format_printf "Vim Plugin Update Logfile..." "yellow" "bold"
    # Display log file with less - replaced with cat for simplicity and proper formatting
    # more "$1"
    cat "$1"
}

# Helper: Empty log file
empty_log() {
    if [[ ! -f "$1" ]]; then
        error_printf "Log file not found: $1"
        return 1
    fi
    
    echo "Logfile Emptied: $(date)" > "$1"
    if logfileline=$(grep "Logfile" "$1" 2>/dev/null); then
        success_printf "$logfileline"
    else
        error_printf "Logfile Line not found"
    fi
}

# Function to get yes/no input
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

# Main script execution
main() {
    local LOG_FILE="$HOME/.logs/vim_plugin_update.log"
    display_header
    
    # Ask if user wants to run pip package update
    if get_yes_no "$(format_printf "Do you want to run Vim Plugin Update?" none "rocket")"; then
        update_vim_plugins
        
        # Prompt to view log
        echo
        get_yes_no "$(format_printf "View log file?" none "log")" && view_log "$LOG_FILE"
        
        # Prompt to empty log
        echo
        get_yes_no "$(format_printf "Empty log file?" none "clean")" && empty_log "$LOG_FILE"
    else
        error_printf "Vim Plugin Update cancelled by user."
    fi
}

# Run the script
main


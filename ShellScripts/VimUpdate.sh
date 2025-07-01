#!/bin/zsh
# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
LOGS_DIR="$HOME/.logs"
LOG_FILE="$LOGS_DIR/vim_plugin_update.log"

[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Function to ensure logs directory exists
ensure_logs_directory() {
    [[ -d "$LOGS_DIR" ]] || {
        if mkdir -p "$LOGS_DIR"; then
            success_printf "Created logs directory: $LOGS_DIR"
        else
            error_printf "Failed to create logs directory: $LOGS_DIR" true
        fi
    }
}

# Display script header
display_header() {
    clear
    format_printf "Vim Plugin Update..." "yellow" "bold"
}

# Update vim plugins
update_vim_plugins() {
    echo | tee -a "$LOG_FILE"
    package_printf "Starting vim plugin update..." | tee -a "$LOG_FILE"
    time_printf "Timestamp: $(date)" | tee -a "$LOG_FILE"
    
    # Check for vim
    command -v mvim >/dev/null || { error_printf "vim is not installed or not in PATH." | tee -a "$LOG_FILE"; return 1; }
    
    # Update vim plugins
    mvim -c 'PlugUpgrade | PlugUpdate | redir >> ~/.logs/vim_plugin_update.log | redir END | qa!' && {
        success_printf "Vim plugin update completed successfully." | tee -a "$LOG_FILE"
    } || {
        error_printf "Vim plugin update failed." | tee -a "$LOG_FILE"
        return 1
    }
    
    return 0
}

# View log file
view_log() {
    [[ -f "$1" ]] || { error_printf "Log file not found: $1"; return 1; }
    [[ -s "$1" ]] || { info_printf "Log file is empty: $1"; return 0; }
    
    clear
    format_printf "Vim Plugin Update Logfile..." "yellow" "bold"
    cat "$1"
}

# Empty log file
empty_log() {
    [[ -f "$1" ]] || { error_printf "Log file not found: $1"; return 1; }
    
    local logline="Logfile Emptied: $(date)"
    echo "$logline" > "$1"
    success_printf "$logline"
}

# Get yes/no input
get_yes_no() {
    local prompt="$1" response
    
    while true; do
        read "response?$prompt (y/n): "
        case ${response:l} in
            y|yes) return 0 ;;
            n|no)  return 1 ;;
            *) format_printf "Please answer yes (Y) or no (N).\n" ;;
        esac
    done
}

# --- Main script execution ---
# Ensure logs directory exists before any operations
ensure_logs_directory

display_header

# Ask if user wants to run plugin update
if get_yes_no "$(format_printf "Do you want to run Vim Plugin Update?" none "rocket")"; then
    update_vim_plugins
    
    # Prompt to view and empty log
    echo
    get_yes_no "$(format_printf "View log file?" none "log")" && view_log "$LOG_FILE"
    echo
    get_yes_no "$(format_printf "Empty log file?" none "clean")" && empty_log "$LOG_FILE"
else
    error_printf "Vim Plugin Update cancelled by user."
fi

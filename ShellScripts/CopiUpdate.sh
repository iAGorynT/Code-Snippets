#!/bin/zsh
# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
LOG_FILE="$HOME/.logs/copi_update.log"

[[ -f "$FORMAT_LIBRARY" ]] || { echo "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Function to display script header
display_header() {
    clear
    format_printf "Copilot Extension Update..." "yellow" "bold"
}

# Function to update pip packages
update_copilot_extension() {
    echo | tee -a "$LOG_FILE"
    package_printf "Starting copilot extension update..." | tee -a "$LOG_FILE"
    time_printf "Timestamp: $(date)" | tee -a "$LOG_FILE"
    
    # Check for pip
    command -v gh >/dev/null || { error_printf "github cli is not installed or not in PATH." | tee -a "$LOG_FILE"; return 1; }
    
    # Upgrade Copilot extension
    upgrade_printf "Checking for copilot extension update..." | tee -a "$LOG_FILE"
    gh extension upgrade gh-copilot >>"$LOG_FILE" 2>&1 && 
        success_printf "copilot extension upgraded successfully." | tee -a "$LOG_FILE" || 
        warning_printf "Failed to upgrade copilot extension." | tee -a "$LOG_FILE"
}

# Helper: View log file
view_log() {
    [[ -f "$1" ]] || { error_printf "Log file not found: $1"; return 1; }
    [[ -s "$1" ]] || { info_printf "Log file is empty: $1"; return 0; }
    
    clear
    format_printf "Copilot Extension Update Logfile..." "yellow" "bold"
    cat "$1"
}

# Helper: Empty log file
empty_log() {
    [[ -f "$1" ]] || { error_printf "Log file not found: $1"; return 1; }
    
    local logline="Logfile Emptied: $(date)"
    echo "$logline" > "$1"
    success_printf "$logline"
}

# Function to get yes/no input
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
display_header

# Ask if user wants to run pip package update
if get_yes_no "$(format_printf "Do you want to run Copilot Extension Update?" none "rocket")"; then
    update_copilot_extension
    
    # Prompt to view log
    echo
    get_yes_no "$(format_printf "View log file?" none "log")" && view_log "$LOG_FILE"
    
    # Prompt to empty log
    echo
    get_yes_no "$(format_printf "Empty log file?" none "clean")" && empty_log "$LOG_FILE"
else
    error_printf "Copilot Extension Update cancelled by user."
fi

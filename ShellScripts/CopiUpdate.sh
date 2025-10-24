#!/bin/zsh
# NOTE: GitHub CLI Copilot Extension Depreciated as of October 25, 2025
# Updated to use new Copilot CLI application.

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
LOGS_DIR="$HOME/.logs"
LOG_FILE="$LOGS_DIR/copi_update.log"

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

# Function to display script header
display_header() {
    clear
    format_printf "Copilot CLI Update..." "yellow" "bold"
}

# Function to compare semantic versions
# Returns 0 if v1 < v2, 1 if v1 >= v2
version_compare() {
    local v1=(${(s:.:)1})
    local v2=(${(s:.:)2})
    
    for i in {1..3}; do
        local num1=${v1[$i]:-0}
        local num2=${v2[$i]:-0}
        
        if (( num1 < num2 )); then
            return 0
        elif (( num1 > num2 )); then
            return 1
        fi
    done
    
    return 1  # versions are equal
}

# Function to update GitHub Copilot CLI
update_copilot_cli() {
    echo | tee -a "$LOG_FILE"
    package_printf "Starting copilot CLI update..." | tee -a "$LOG_FILE"
    time_printf "Timestamp: $(date)" | tee -a "$LOG_FILE"

    # Get currently installed version
    current_version=$(npm list -g @github/copilot --depth=0 2>/dev/null | grep @github/copilot | sed -E 's/.*@([0-9.]+).*/\1/')
    # Exit if not installed
    if [[ -z "$current_version" ]]; then
        error_printf "@github/copilot is not installed or not in PATH." | tee -a "$LOG_FILE"
	return 1
    fi
    # Get latest available version
    latest_version=$(npm view @github/copilot version)
    
    if version_compare "$current_version" "$latest_version"; then
        npm install -g @github/copilot@latest >>"$LOG_FILE" 2>&1 &&
	    success_printf "@github/copilot updated successfully to v$latest_version." | tee -a "$LOG_FILE" ||
	    warning_printf "Failed to update @github/copilot." | tee -a "$LOG_FILE"
    else
        info_printf "@github/copilot is already up to date (v$current_version)" | tee -a "$LOG_FILE"
    fi
}

# Helper: View log file
view_log() {
    [[ -f "$1" ]] || { error_printf "Log file not found: $1"; return 1; }
    [[ -s "$1" ]] || { info_printf "Log file is empty: $1"; return 0; }
    
    clear
    format_printf "Copilot CLI Update Logfile..." "yellow" "bold"
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
# Ensure logs directory exists before any operations
ensure_logs_directory

display_header

# Ask if user wants to run copilot CLI update
if get_yes_no "$(format_printf "Do you want to run Copilot CLI Update?" none "rocket")"; then
    update_copilot_cli
    
    # Prompt to view log
    echo
    get_yes_no "$(format_printf "View log file?" none "log")" && view_log "$LOG_FILE"
    
    # Prompt to empty log
    echo
    get_yes_no "$(format_printf "Empty log file?" none "clean")" && empty_log "$LOG_FILE"
else
    error_printf "Copilot CLI Update cancelled by user."
fi

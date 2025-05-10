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
    format_printf "Pip Package Update..." "yellow" "bold"
}

# Function to update pip packages
update_pip_packages() {
    local LOG_FILE="$HOME/.logs/pip_update.log"
    echo | tee -a "$LOG_FILE"
    package_printf "Starting pip package update..." | tee -a "$LOG_FILE"
    time_printf "Timestamp: $(date)" | tee -a "$LOG_FILE"
    
    # Check for pip
    if ! command -v pip >/dev/null; then
        error_printf "pip is not installed or not in PATH." | tee -a "$LOG_FILE"
        return 1
    fi
    
    # Self-upgrade pip
    upgrade_printf "Checking for pip update..." | tee -a "$LOG_FILE"
    if pip install --upgrade pip >>"$LOG_FILE" 2>&1; then
        success_printf "pip upgraded successfully." | tee -a "$LOG_FILE"
    else
        warning_printf "Failed to upgrade pip. Continuing with package updates..." | tee -a "$LOG_FILE"
    fi
    
    # Get list of outdated packages (excluding pip)
    local outdated_json=$(pip list --outdated --format=json)
    local packages=()
    
    # More robust JSON parsing
    if [[ -n "$outdated_json" ]]; then
        while IFS= read -r pkg; do
            [[ -n "$pkg" ]] && packages+=("$pkg")
        done < <(echo "$outdated_json" | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
    for p in data:
        name = p.get("name", "").strip()
        if name.lower() != "pip" and name:
            print(name)
except json.JSONDecodeError:
    print("Error parsing JSON data", file=sys.stderr)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
')
    fi
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        success_printf "No outdated packages to update." | tee -a "$LOG_FILE"
    else
        update_printf "Updating the following packages:" | tee -a "$LOG_FILE"
        printf "%s\n" "${packages[@]}" | tee -a "$LOG_FILE"
        
        local successful=0
        local failed=0
        
        for pkg in "${packages[@]}"; do
            upgrade_printf "Updating $pkg..." | tee -a "$LOG_FILE"
            if pip install -U "$pkg" >>"$LOG_FILE" 2>&1; then
                success_printf "$pkg updated successfully." | tee -a "$LOG_FILE"
                ((successful++))
            else
                error_printf "Failed to update $pkg. Check log for details." | tee -a "$LOG_FILE"
                ((failed++))
            fi
        done
        
        echo | tee -a "$LOG_FILE"
        stats_printf "Summary: Updated $successful package(s), failed $failed package(s)" | tee -a "$LOG_FILE"
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
    format_printf "Pip Package Update Logfile..." "yellow" "bold"
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
    local LOG_FILE="$HOME/.logs/pip_update.log"
    display_header
    
    # Ask if user wants to run pip package update
    if get_yes_no "$(format_printf "Do you want to run Pip Package Update?" none "rocket")"; then
        update_pip_packages
        
        # Prompt to view log
        echo
        get_yes_no "$(format_printf "View log file?" none "log")" && view_log "$LOG_FILE"
        
        # Prompt to empty log
        echo
        get_yes_no "$(format_printf "Empty log file?" none "clean")" && empty_log "$LOG_FILE"
    else
        error_printf "Pip Package Update cancelled by user."
    fi
}

# Run the script
main

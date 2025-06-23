#!/bin/zsh
# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
LOGS_DIR="$HOME/.logs"
LOG_FILE="$LOGS_DIR/python_update.log"

[[ -f "$FORMAT_LIBRARY" ]] || { echo "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Check required tools
for tool in curl python3 pyenv; do
    command -v "$tool" >/dev/null 2>&1 || { error_printf "Required tool '$tool' not found. Please install it first."; exit 1; }
done

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

# Get yes/no input
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

# View log file
view_log() {
    [[ -f "$1" ]] || { error_printf "Log file not found: $1"; return 1; }
    [[ -s "$1" ]] || { info_printf "Log file is empty: $1"; return 0; }
    clear
    format_printf "Python Update Logfile..." "yellow" "bold"
    cat "$1"
}

# Empty log file
empty_log() {
    [[ -f "$1" ]] || { error_printf "Log file not found: $1"; return 1; }
    
    local logline="Logfile Emptied: $(date)"
    echo "$logline" > "$1"
    success_printf "$logline"
}

# --- Main script execution ---
# Ensure logs directory exists before any operations
ensure_logs_directory

clear
format_printf "Python Update..." "yellow" "bold"
printf "\n"

# Get current and latest Python versions
current_python=$(python3 --version | awk '{print $2}')
info_printf "Current Python version: $current_python"

latest_python=$(curl -s https://api.github.com/repos/python/cpython/tags | 
                grep -o '"name": "v[0-9]\+\.[0-9]\+\.[0-9]\+"' | 
                sed 's/"name": "v//;s/"//g' | 
                sort -V | 
                tail -1)
info_printf "Latest Python version: $latest_python"
printf "\n"

if [[ "$current_python" == "$latest_python" ]]; then
    success_printf "Python is up to date"
else
    warning_printf "Python is not up to date"
    printf "\n"
    
    # Check if pyenv is up-to-date with the latest Python version
    major_version=$(echo "$latest_python" | cut -d'.' -f1)
    pyenv_latest=$(pyenv latest -k "$major_version" 2>/dev/null || echo "")
    
    if [[ -z "$pyenv_latest" ]] || [[ "$pyenv_latest" != "$latest_python" ]]; then
        error_printf "pyenv must be updated before Python update can be done. Latest available in pyenv: ${pyenv_latest:-'unknown'}, Required: $latest_python" true
    fi
    
    success_printf "pyenv is up-to-date with Python $latest_python"
    printf "\n"
    
    if get_yes_no "$(format_printf "Do you want to update Python?" none "rocket")"; then
        package_printf "Starting Python update..." | tee -a "$LOG_FILE"
        time_printf "Timestamp: $(date)" | tee -a "$LOG_FILE"
        
        pyenv install "$latest_python" | tee -a "$LOG_FILE" || 
            { error_printf "Python installation failed. Check the logs." | tee -a "$LOG_FILE"; exit 1; }
        
        pyenv global "$latest_python" | tee -a "$LOG_FILE"
        printf "\n" | tee -a "$LOG_FILE"

        package_printf "Installing Python packages from requirements.txt..." | tee -a "$LOG_FILE"
        if [[ -f "$HOME/PythonCode/requirements.txt" ]]; then
            python3 -m pip install -r "$HOME/PythonCode/requirements.txt" | tee -a "$LOG_FILE" || 
                { error_printf "Requirements installation failed. Check the logs." | tee -a "$LOG_FILE"; }
        else
            error_printf "Requirements file not found at $HOME/PythonCode/requirements.txt" | tee -a "$LOG_FILE"
        fi
        printf "\n" | tee -a "$LOG_FILE"

        success_printf "Python updated to version: $latest_python" | tee -a "$LOG_FILE"
        printf "\n"
        
        get_yes_no "$(format_printf "View log file?" none "log")" && view_log "$LOG_FILE"
        printf "\n"
        get_yes_no "$(format_printf "Empty log file?" none "clean")" && empty_log "$LOG_FILE"
    else
        error_printf "Python Update cancelled by user."
    fi
fi

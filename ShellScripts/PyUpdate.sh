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
    format_printf "Python Update..." "yellow" "bold"
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
    format_printf "Python Update Logfile..." "yellow" "bold"
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

# Helper: Check if tool exists
check_dependency() {
    local tool="$1"
    if ! command -v "$tool" >/dev/null 2>&1; then
        error_printf "Required tool '$tool' not found. Please install it first."
        exit 1
    fi
}

# Main script execution
main() {
    local LOG_FILE="$HOME/.logs/python_update.log"
    check_dependency "curl"
    check_dependency "python3"
    check_dependency "pyenv"

    display_header
    printf "\n"

    # Get current and latest version of python
    current_python=$(python3 --version | awk '{print $2}')
    info_printf "Current Python version: $current_python"

    # Get the latest Python version from GitHub
    latest_python=$(curl -s https://api.github.com/repos/python/cpython/tags | \
        grep -o '"name": "v[0-9]\+\.[0-9]\+\.[0-9]\+"' | \
        sed 's/\"name\": \"v//' | \
        sed 's/\"//' | \
        sort -V | \
        tail -1)
    info_printf "Latest Python version: $latest_python"
    printf "\n"

    if [[ "$current_python" == "$latest_python" ]]; then
        success_printf "Python is up to date"
    else
        info_printf "Python is not up to date"
        printf "\n"

        if get_yes_no "$(format_printf "Do you want to update Python?" none "rocket")"; then
            package_printf "Starting Python update..." | tee -a "$LOG_FILE"
            time_printf "Timestamp: $(date)" | tee -a "$LOG_FILE"

            if ! pyenv install "$latest_python" | tee -a "$LOG_FILE"; then
                error_printf "Python installation failed. Check the logs." | tee -a "$LOG_FILE"
                exit 1
            fi

            pyenv global "$latest_python" | tee -a "$LOG_FILE"
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
}

# Run the script
main


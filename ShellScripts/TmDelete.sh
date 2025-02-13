#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

# Configuration
LOGFILE="${HOME}/tm_snapshot_cleanup.log"
LOGDIR="${LOGFILE%/*}"

# Ensure log directory exists
[[ -d "$LOGDIR" ]] || mkdir -p "$LOGDIR"

# Check if running with sudo
if [[ $EUID -ne 0 ]]; then
    printf "This script requires administrative privileges.\n"
    printf "Please run with sudo.\n"
    exit 1
fi

# Function to log messages
log_message() {
    local message="$(date '+%Y-%m-%d %H:%M:%S'): $1"
    printf "%s\n" "$message" | tee -a "$LOGFILE"
}

# Function to check available disk space before and after
check_space() {
    df -h / | grep -v "Filesystem"
}

# Main cleanup process
cleanup_snapshots() {
    local before_space=$(check_space)
    log_message "Starting local snapshot cleanup"
    log_message "Space before cleanup:"
    printf "%s\n" "$before_space" | tee -a "$LOGFILE"
    
    # List existing snapshots before deletion
    log_message "Existing snapshots:"
    tmutil listlocalsnapshots / | tee -a "$LOGFILE"
    
    # Delete all local snapshots
    if tmutil deletelocalsnapshots / 2>&1 | tee -a "$LOGFILE"; then
        local after_space=$(check_space)
        log_message "Cleanup completed successfully"
        log_message "Space after cleanup:"
        printf "%s\n" "$after_space" | tee -a "$LOGFILE"
    else
        log_message "Error: Cleanup failed"
        return 1
    fi
}

# Main script
main() {
    clear
    format_printf "Time Machine Snapshots..." "yellow" "bold"
    printf "\n"
    printf "This will delete all local Time Machine snapshots.\n"
    printf "Please make sure you have a recent backup before proceeding.\n\n"
    
    read -q "REPLY?Are you sure you want to continue? (y/n) "
    printf "\n"
    
    if [[ $REPLY == "y" ]]; then
        cleanup_snapshots
    else
        printf "Operation canceled.\n"
        exit 0
    fi
}

main "$@"

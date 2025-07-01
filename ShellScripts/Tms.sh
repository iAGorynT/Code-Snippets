#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    printf "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

clear
format_printf "Time Machine Snapshots..." "yellow" "bold"
printf "\n"

# List Time Machine Snapshots
tmutil listlocalsnapshots /


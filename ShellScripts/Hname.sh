#!/bin/zsh

# Source function library with error handling

SCRIPT_DIR="${0:a:h}"
FORMAT_LIBRARY="$SCRIPT_DIR/FLibFormatPrintf.sh"

if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    printf "Error: Required library not found: %s\n" "$FORMAT_LIBRARY" >&2
    printf "Searched in script directory: %s\n" "$SCRIPT_DIR" >&2
    exit 1
fi

source "$FORMAT_LIBRARY"

clear
format_printf "Hostname Information..." "yellow" "bold"
printf "\n"

# Display Hostname
echo "Computer Hostname: " $(hostname -f)
echo " "

# Display IP Addresses 
echo "IP Addresses:"
ifconfig | grep "inet " | grep -v 127.0.0.1
echo " "

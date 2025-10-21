#!/bin/zsh
# Standard Message Formatting Library and Functions
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
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

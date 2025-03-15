#!/bin/zsh

# Function Library Documentation

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    echo "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

clear
format_printf "Function Library Format Printf Documentation..." yellow bold
echo " "

# Build Search Strings
# Start
liststart="# Function:"
# End
listend="# Echotype:"

# Initialize Variables
zshrcfile="$HOME/ShellScripts/FLibFormatPrintf.sh"
if [[ ! -r "$zshrcfile" ]]; then
    echo "File not found or not readable: $zshrcfile"
    echo
    exit 1
fi
start=false

while IFS= read -r line; do
    # Check if line begins with Category Start
    if [[ $line == *"$liststart"* ]]; then
        start=true
    fi

    # If start is true, display the line
    if [ "$start" = true ]; then
        echo "$line"
    fi

    # Check if line begins with Category End
    if [[ $line == *"$listend"* ]]; then
        echo
        start=false
    fi
done < "$zshrcfile"

# Show Expamples
echo
FLibFormatPrintf.sh
echo

format_printf "Function Library Documentation Complete..." green bold
echo


#!/bin/zsh

# Function Library Documentation

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
format_printf "Function Library Format Printf Documentation..." yellow bold
echo " "

# Build Search Strings
# Start
liststart="# Function:"
# End
listend="# Icon:"

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


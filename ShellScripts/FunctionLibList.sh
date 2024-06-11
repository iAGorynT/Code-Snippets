#!/bin/zsh

# Function Library List

clear
echo "Function Library List..."
echo " "

# Build Search Strings
# Start
liststart="# Function:"
# End
listend="# Usage:"

# Initialize Variables
zshrcfile="$HOME/ShellScripts/FunctionLib.sh"
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


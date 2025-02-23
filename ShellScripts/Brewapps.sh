#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatEcho.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    echo "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

# List Selected Application Descriptions
clear
format_echo "App Descriptions..." "yellow" "bold"
echo " "

# Array of app names
apps=("gauth:" "iperf3:" "jq:" "qlmarkdown:" "macdown:" "speedtest:" "github:" "macvim:" "syntax-highlight:")

# Function to check if a line contains an app name
contains_app() {
    local line=$1
    for app in "${apps[@]}"; do
        if [[ $line == *"$app"* ]]; then
            echo "$line"
            break
        fi
    done
}

# Temporary file to store brew command results
    temp_file=$(mktemp)
# Run the command and store output in a temporary file
    brew desc --eval-all $(brew list) | awk 'gsub(/^([^:]*?)\s*:\s*/,"&=")' | column -s "=" -t > $temp_file

# Read file line by line and check for app names
while IFS= read -r line; do
    contains_app "$line"
done < $temp_file


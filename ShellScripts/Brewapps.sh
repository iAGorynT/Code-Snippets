#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# List Selected Application Descriptions
clear
format_printf "App Descriptions..." "yellow" "bold"
printf "\n"

# Array of app names
apps=("uv:" "iperf3:" "jq:" "node:" "speedtest:" "github:" "macvim-app:" "somo:")

# Function to check if a line starts with an app name
contains_app() {
    local line="$1"
    for app in "${apps[@]}"; do
        if [[ "$line" == "$app"* ]]; then
            echo "$line"
            break
        fi
    done
}

# Temporary file to store brew command results
    temp_file=$(mktemp)
# Run the command and store output in a temporary file and redirect stderr to /dev/null to suppress errors
    brew desc --eval-all $(brew list) 2>/dev/null | awk 'gsub(/^([^:]*?)\s*:\s*/,"&=")' | column -s "=" -t > $temp_file

# Read file line by line and check for app names
while IFS= read -r line; do
    contains_app "$line"
done < $temp_file


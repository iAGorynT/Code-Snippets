#!/bin/zsh
# List global npm packages

# Source function library with error handling

FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

clear
format_printf "Global NPM Packages List..." "yellow" "bold"
printf "\n"

# Global npm packages (excluding npm itself)
npm list -g --depth=0


#!/bin/zsh
# Outdated npm packages

# Source function library with error handling

FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

clear
format_printf "Outdated NPM Packages..." "yellow" "bold"
printf "\n"

# Check for outdated global npm packages
npm outdated -g --depth=0


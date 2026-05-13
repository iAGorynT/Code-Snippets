#!/bin/zsh
# Outdated npm packages

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
format_printf "Outdated NPM Packages..." "yellow" "bold"
printf "\n"

# Check that npm is available on the system
if ! command -v npm &>/dev/null; then
  error_printf "npm is not installed or not in PATH. Please install Node.js/npm first." true
  exit 1
fi

# Check for outdated global npm packages
npm outdated -g --depth=0


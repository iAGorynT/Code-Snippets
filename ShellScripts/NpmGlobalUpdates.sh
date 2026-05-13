#!/bin/zsh
# Update global npm packages

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
rocket_printf "Starting NPM global package updates..."
printf "\n"

# Check that npm is available on the system
if ! command -v npm &>/dev/null; then
  error_printf "npm is not installed or not in PATH. Please install Node.js/npm first." true
  exit 1
fi

info_printf "Checking outdated global npm packages (excluding npm)..."

packages=(${(f)"$(npm outdated -g --parseable --depth=0 \
  | cut -d: -f2 \
  | sed 's/@.*//' \
  | grep -v '^npm$')"})

if (( ${#packages[@]} == 0 )); then
  success_printf "All global packages are up to date!"
else
  package_printf "Updating: ${packages[@]}"
  for pkg in "${packages[@]}"; do
    npm install -g "$pkg"
  done
  success_printf "Global packages update completed"
fi

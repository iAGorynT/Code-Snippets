#!/bin/zsh
# Update global npm packages

# Source function library with error handling

FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

clear
rocket_printf "Starting npm global package updates..."
printf "\n"

info_printf "Checking outdated global npm packages (excluding npm)..."

local packages
packages=(${(f)"$(npm outdated -g --parseable --depth=0 \
  | cut -d: -f2 \
  | sed 's/@.*//' \
  | grep -v '^npm$')"})

if (( ${#packages[@]} == 0 )); then
  success_printf "All global packages are up to date!"
  exit 0
fi

package_printf "Updating: ${packages[@]}"

for pkg in "${packages[@]}"; do
  npm install -g "$pkg"
done

success_printf "Global packages update completed"

#!/bin/zsh
# Update global npm/bun packages

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
rocket_printf "Starting global package updates..."
printf "\n"

# Check runtimes availability
HAS_NPM=false
HAS_BUN=false

if command -v npm &>/dev/null; then
  HAS_NPM=true
fi

if command -v bun &>/dev/null; then
  HAS_BUN=true
fi

if [[ "$HAS_NPM" == false && "$HAS_BUN" == false ]]; then
  error_printf "Neither npm nor bun is installed or not in PATH. Please install Node.js/npm or bun first." true
  exit 1
fi

# Select runtime
if [[ "$HAS_NPM" == true && "$HAS_BUN" == true ]]; then
  info_printf "Select runtime to update global packages:"
  printf "1) npm\n"
  printf "2) bun\n"
  printf "\n"
  while true; do
    read -k 1 "choice?Enter your choice (1 or 2): "
    printf "\n"
    case $choice in
      1) break ;;
      2) break ;;
      *) warning_printf "Invalid choice. Please enter 1 for npm or 2 for bun." ;;
    esac
  done
elif [[ "$HAS_BUN" == true ]]; then
  choice=2
else
  choice=1
fi

printf "\n"

if [[ "$choice" == "1" ]]; then
  info_printf "Checking outdated global npm packages (excluding npm)..."

  packages=(${(f)"$(npm outdated -g --parseable --depth=0 \
    | cut -d: -f2 \
    | sed 's/@.*//' \
    | grep -v '^npm$')"})

  if (( ${#packages[@]} == 0 )); then
    success_printf "All global npm packages are up to date!"
  else
    package_printf "Updating: ${packages[@]}"
    for pkg in "${packages[@]}"; do
      npm install -g "$pkg"
    done
    success_printf "Global npm packages update completed"
  fi
elif [[ "$choice" == "2" ]]; then
  BUN_GLOBAL_DIR="$HOME/.bun/install/global"
  if [[ -f "$BUN_GLOBAL_DIR/package.json" ]]; then
    if command -v jq &> /dev/null; then
      deps=$(jq -r '.dependencies // {} | to_entries | map("\(.key)@\(.value)") | .[]' "$BUN_GLOBAL_DIR/package.json")
      if [[ -n "$deps" ]]; then
        info_printf "Updating globally installed bun packages..."
        packages=(${(@f)"$(jq -r '.dependencies // {} | keys[]' "$BUN_GLOBAL_DIR/package.json")"})
        for pkg in "${packages[@]}"; do
          bun install -g "$pkg"
        done
        success_printf "Global bun packages update completed"
      else
        success_printf "All global bun packages are up to date!"
      fi
    else
      packages=($(ls -1 "$BUN_GLOBAL_DIR/node_modules/" 2>/dev/null | grep -v '^\.'))
      if (( ${#packages[@]} == 0 )); then
        success_printf "All global bun packages are up to date!"
      else
        info_printf "Updating globally installed bun packages (install jq for version info)..."
        for pkg in "${packages[@]}"; do
          bun install -g "$pkg"
        done
        success_printf "Global bun packages update completed"
      fi
    fi
  else
    info_printf "No globally installed packages found via bun."
    info_printf "Install with: bun install -g <package>"
  fi
fi

#!/bin/zsh
# List global npm/bun packages

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
format_printf "Global Npm/Bun Packages List..." "yellow" "bold"
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
  info_printf "Select runtime to list global packages:"
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
  npm list -g --depth=0
elif [[ "$choice" == "2" ]]; then
  BUN_GLOBAL_DIR="$HOME/.bun/install/global"
  if [[ -f "$BUN_GLOBAL_DIR/package.json" ]]; then
    if command -v jq &> /dev/null; then
      deps=$(jq -r '.dependencies // {} | to_entries | map("\(.key)@\(.value)") | .[]' "$BUN_GLOBAL_DIR/package.json")
      if [[ -n "$deps" ]]; then
        info_printf "Globally installed bun packages:"
        printf "%s\n" "$deps"
      else
        info_printf "No globally installed packages found via bun."
      fi
    else
      info_printf "Globally installed bun packages (install jq for version info):"
      ls -1 "$BUN_GLOBAL_DIR/node_modules/" 2>/dev/null | grep -v '^\.' || info_printf "No globally installed packages found via bun."
    fi
  else
    info_printf "No globally installed packages found via bun."
    info_printf "Install with: bun install -g <package>"
  fi
fi

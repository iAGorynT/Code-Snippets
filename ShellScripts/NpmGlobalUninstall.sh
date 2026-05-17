#!/bin/zsh
# Uninstall and fully clean up a globally installed npm/bun package

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
rocket_printf "Starting global package uninstall..."
printf '\n'

# Check if sudo is available for privilege escalation
SUDO_AVAILABLE=false
command -v sudo &>/dev/null && SUDO_AVAILABLE=true

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
  info_printf "Select runtime:"
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

# Set runtime-specific variables
if [[ "$choice" == "1" ]]; then
  GLOBAL_DIR=$(npm root -g 2>/dev/null) || { error_printf "Failed to get npm global directory" true; exit 1; }
  BIN_DIR="$(npm config get prefix 2>/dev/null)/bin"
  if [[ ! -d "$BIN_DIR" ]]; then
    error_printf "Failed to determine npm bin directory" true
    exit 1
  fi
  INSTALL_CMD=(npm install -g)
  UNINSTALL_CMD=(npm uninstall -g)
else
  GLOBAL_DIR="$HOME/.bun/install/global/node_modules"
  BIN_DIR="$HOME/.bun/bin"
  INSTALL_CMD=(bun install -g)
  UNINSTALL_CMD=(bun remove -g)
fi

# Parse command line arguments
TEST_MODE=false
if [[ "$1" == "-t" || "$1" == "--test" ]]; then
  TEST_MODE=true
  shift
fi

# If in test mode, install 'yo' globally for testing
if [[ "$TEST_MODE" == true ]]; then
  info_printf "TEST MODE: Installing 'yo' globally for testing..."
  if ! "${INSTALL_CMD[@]}" yo 2>/dev/null; then
    if [[ "$SUDO_AVAILABLE" == true ]]; then
      warning_printf "Permission denied, trying with sudo..."
      if ! sudo "${INSTALL_CMD[@]}" yo; then
        error_printf "Failed to install 'yo' for testing. Check permissions or internet connection." true
      fi
    else
      error_printf "Failed to install 'yo' for testing. Check permissions or internet connection." true
    fi
  fi
  info_printf "TEST MODE: 'yo' package installed. Enter 'yo' at the prompt to test uninstall."
  printf '\n'
fi

# Prompt user for package name with validation
while true; do
  read "PACKAGE?Enter the name of the global package to uninstall: "
  if [[ -z "$PACKAGE" ]]; then
    error_printf "Package name cannot be empty. Please try again."
  else
    break
  fi
done

info_printf "Checking for global package: $PACKAGE"

# Step 1: Check if package is actually installed
if [[ ! -d "$GLOBAL_DIR/$PACKAGE" ]]; then
  success_printf "$PACKAGE not found in global packages."
  INSTALLED=false
else
  package_printf "Found $PACKAGE at: $GLOBAL_DIR/$PACKAGE"
  INSTALLED=true

  # Get list of binaries this package provides before uninstalling
  BINARIES=()
  if [[ -f "$GLOBAL_DIR/$PACKAGE/package.json" ]]; then
    BINARIES=($(node -pe "
      try {
        const pkg = require('$GLOBAL_DIR/$PACKAGE/package.json');
        if (typeof pkg.bin === 'string') {
          console.log('$PACKAGE');
        } else if (typeof pkg.bin === 'object') {
          console.log(Object.keys(pkg.bin).join(' '));
        }
      } catch(e) {}
    " 2>/dev/null))
  fi
fi

# Step 2: Confirm and uninstall globally
if [[ "$INSTALLED" == true ]]; then
  format_printf "Ready to uninstall $PACKAGE" "blue" "bold" "🧩"
  read -k "CONFIRM?Proceed with uninstall? (y/N): "
  printf '\n'
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    info_printf "Uninstall cancelled."
    exit 0
  fi

  format_printf "Uninstalling $PACKAGE..." "blue" "bold" "🧩"
  "${UNINSTALL_CMD[@]}" "$PACKAGE" 2>/dev/null

  if [[ $? -ne 0 ]]; then
    if [[ "$SUDO_AVAILABLE" == true ]]; then
      warning_printf "Permission denied, trying with sudo..."
      sudo "${UNINSTALL_CMD[@]}" "$PACKAGE"
    else
      warning_printf "Uninstall failed. Try running with appropriate permissions."
    fi
  fi
fi

# Step 3: Remove any lingering binaries
if [[ ${#BINARIES[@]} -gt 0 ]]; then
  clean_printf "Checking for leftover binaries..."
  for BIN in "${BINARIES[@]}"; do
    BIN_PATH="$BIN_DIR/$BIN"
    if [[ -L "$BIN_PATH" ]] || [[ -f "$BIN_PATH" ]]; then
      format_printf "Removing: $BIN_PATH" "cyan" "italic" "⚙️ "
      rm -f "$BIN_PATH" 2>/dev/null
      if [[ $? -ne 0 && "$SUDO_AVAILABLE" == true ]]; then
        sudo rm -f "$BIN_PATH"
      fi
    fi
  done
else
  # Fallback: check for binary matching package name
  BIN_PATH="$BIN_DIR/$PACKAGE"
  if [[ -L "$BIN_PATH" ]] || [[ -f "$BIN_PATH" ]]; then
    clean_printf "Removing binary: $BIN_PATH"
    rm -f "$BIN_PATH" 2>/dev/null
    if [[ $? -ne 0 && "$SUDO_AVAILABLE" == true ]]; then
      sudo rm -f "$BIN_PATH"
    fi
  fi
fi

# Step 4: Clean up package directory if it still exists
if [[ -d "$GLOBAL_DIR/$PACKAGE" ]]; then
  format_printf "Removing leftover package directory..." "green" "italic" "🗑️ "
  rm -rf "$GLOBAL_DIR/$PACKAGE" 2>/dev/null
  if [[ $? -ne 0 && "$SUDO_AVAILABLE" == true ]]; then
    sudo rm -rf "$GLOBAL_DIR/$PACKAGE"
  fi
fi

# Step 5: Verify removal
format_printf "Verifying cleanup..." "blue" "bold" "🔎"
ISSUES=()

# Check if package directory still exists
if [[ -d "$GLOBAL_DIR/$PACKAGE" ]]; then
  ISSUES+=("Package directory still exists: $GLOBAL_DIR/$PACKAGE")
fi

# Check if any binaries still exist
if [[ ${#BINARIES[@]} -gt 0 ]]; then
  for BIN in "${BINARIES[@]}"; do
    if which "$BIN" >/dev/null 2>&1; then
      ISSUES+=("Binary '$BIN' still found in PATH: $(which $BIN)")
    fi
  done
else
  if which "$PACKAGE" >/dev/null 2>&1; then
    ISSUES+=("Command '$PACKAGE' still found in PATH: $(which $PACKAGE)")
  fi
fi

if [[ ${#ISSUES[@]} -gt 0 ]]; then
  error_printf "Issues found:"
  for ISSUE in "${ISSUES[@]}"; do
    printf '   - %s\n' "$ISSUE"
  done
  printf 'You may need to remove these manually or check your PATH.\n'
  exit 1
else
  success_printf "$PACKAGE fully removed from your system!"
fi

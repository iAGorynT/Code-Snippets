#!/bin/zsh
# Uninstall and fully clean up a globally installed npm package

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
rocket_printf "Starting NPM global package uninstall..."
printf '\n'

# Check if sudo is available for privilege escalation
SUDO_AVAILABLE=false
command -v sudo &>/dev/null && SUDO_AVAILABLE=true

# Parse command line arguments
TEST_MODE=false
if [[ "$1" == "-t" || "$1" == "--test" ]]; then
  TEST_MODE=true
  shift
fi

# If in test mode, install 'yo' globally for testing
if [[ "$TEST_MODE" == true ]]; then
  info_printf "TEST MODE: Installing 'yo' globally for testing..."
  if ! npm install -g yo 2>/dev/null; then
    if [[ "$SUDO_AVAILABLE" == true ]]; then
      warning_printf "Permission denied, trying with sudo..."
      if ! sudo npm install -g yo; then
        error_printf "Failed to install 'yo' for testing. Check permissions or internet connection." true
      fi
    else
      error_printf "Failed to install 'yo' for testing. Check permissions or internet connection." true
    fi
  fi
  info_printf "TEST MODE: 'yo' package installed. Enter 'yo' at the prompt to test uninstall."
  printf '\n'
fi

# Check that npm is available on the system
if ! command -v npm &>/dev/null; then
  error_printf "npm is not installed or not in PATH. Please install Node.js/npm first." true
  exit 1
fi

# Prompt user for package name with validation
while true; do
  read "PACKAGE?Enter the name of the global npm package to uninstall: "
  if [[ -z "$PACKAGE" ]]; then
    error_printf "Package name cannot be empty. Please try again."
  else
    break
  fi
done

info_printf "Checking for global npm package: $PACKAGE"

# Get npm global directories
NPM_GLOBAL_DIR=$(npm root -g 2>/dev/null) || { error_printf "Failed to get npm global directory" true; exit 1; }
NPM_BIN_DIR="$(npm config get prefix 2>/dev/null)/bin"
if [[ ! -d "$NPM_BIN_DIR" ]]; then
    error_printf "Failed to determine npm bin directory" true
  exit 1
fi

# Step 1: Check if package is actually installed
if [[ ! -d "$NPM_GLOBAL_DIR/$PACKAGE" ]]; then
  success_printf "$PACKAGE not found in global npm packages."
  INSTALLED=false
else
  package_printf "Found $PACKAGE at: $NPM_GLOBAL_DIR/$PACKAGE"
  INSTALLED=true

  # Get list of binaries this package provides before uninstalling
  BINARIES=()
  if [[ -f "$NPM_GLOBAL_DIR/$PACKAGE/package.json" ]]; then
    BINARIES=($(node -pe "
      try {
        const pkg = require('$NPM_GLOBAL_DIR/$PACKAGE/package.json');
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
  npm uninstall -g "$PACKAGE" 2>/dev/null

  if [[ $? -ne 0 ]]; then
    if [[ "$SUDO_AVAILABLE" == true ]]; then
      warning_printf "Permission denied, trying with sudo..."
      sudo npm uninstall -g "$PACKAGE"
    else
      warning_printf "Permission denied and sudo is not available. Try running as root."
    fi
  fi
fi

# Step 3: Remove any lingering binaries
if [[ ${#BINARIES[@]} -gt 0 ]]; then
  clean_printf "Checking for leftover binaries..."
  for BIN in "${BINARIES[@]}"; do
    BIN_PATH="$NPM_BIN_DIR/$BIN"
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
  BIN_PATH="$NPM_BIN_DIR/$PACKAGE"
  if [[ -L "$BIN_PATH" ]] || [[ -f "$BIN_PATH" ]]; then
    clean_printf "Removing binary: $BIN_PATH"
    rm -f "$BIN_PATH" 2>/dev/null
    if [[ $? -ne 0 && "$SUDO_AVAILABLE" == true ]]; then
      sudo rm -f "$BIN_PATH"
    fi
  fi
fi

# Step 4: Clean up package directory if it still exists
if [[ -d "$NPM_GLOBAL_DIR/$PACKAGE" ]]; then
  format_printf "Removing leftover package directory..." "green" "italic" "🗑️ "
  rm -rf "$NPM_GLOBAL_DIR/$PACKAGE" 2>/dev/null
  if [[ $? -ne 0 && "$SUDO_AVAILABLE" == true ]]; then
    sudo rm -rf "$NPM_GLOBAL_DIR/$PACKAGE"
  fi
fi

# Step 5: Verify removal
format_printf "Verifying cleanup..." "blue" "bold" "🔎"
ISSUES=()

# Check if package directory still exists
if [[ -d "$NPM_GLOBAL_DIR/$PACKAGE" ]]; then
  ISSUES+=("Package directory still exists: $NPM_GLOBAL_DIR/$PACKAGE")
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

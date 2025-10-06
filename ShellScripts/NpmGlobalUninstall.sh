#!/bin/zsh
# Uninstall and fully clean up a globally installed npm package

clear
echo "🚀 Starting npm global package cleanup..."
echo

if [[ -z "$1" ]]; then
  echo "Usage: $0 <package-name>"
  exit 1
fi

PACKAGE="$1"
echo "🔍 Checking for global npm package: $PACKAGE"

# Get npm global directories
NPM_GLOBAL_DIR=$(npm root -g)
NPM_BIN_DIR=$(npm bin -g)

# Step 1: Check if package is actually installed
if [[ ! -d "$NPM_GLOBAL_DIR/$PACKAGE" ]]; then
  echo "✅ $PACKAGE not found in global npm packages."
  INSTALLED=false
else
  echo "📦 Found $PACKAGE at: $NPM_GLOBAL_DIR/$PACKAGE"
  INSTALLED=true
  
  # Get list of binaries this package provides before uninstalling
  BINARIES=()
  if [[ -f "$NPM_GLOBAL_DIR/$PACKAGE/package.json" ]]; then
    # Extract bin entries from package.json
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

# Step 2: Uninstall globally
if [[ "$INSTALLED" == true ]]; then
  echo "🧩 Uninstalling $PACKAGE..."
  npm uninstall -g "$PACKAGE" 2>/dev/null
  
  # Check if uninstall failed due to permissions
  if [[ $? -ne 0 ]]; then
    echo "⚠️ Permission denied, trying with sudo..."
    sudo npm uninstall -g "$PACKAGE"
  fi
fi

# Step 3: Remove any lingering binaries
if [[ ${#BINARIES[@]} -gt 0 ]]; then
  echo "🧹 Checking for leftover binaries..."
  for BIN in "${BINARIES[@]}"; do
    BIN_PATH="$NPM_BIN_DIR/$BIN"
    if [[ -L "$BIN_PATH" ]] || [[ -f "$BIN_PATH" ]]; then
      echo "⚙️ Removing: $BIN_PATH"
      sudo rm -f "$BIN_PATH"
    fi
  done
else
  # Fallback: check for binary matching package name
  BIN_PATH="$NPM_BIN_DIR/$PACKAGE"
  if [[ -L "$BIN_PATH" ]] || [[ -f "$BIN_PATH" ]]; then
    echo "🧹 Removing binary: $BIN_PATH"
    sudo rm -f "$BIN_PATH"
  fi
fi

# Step 4: Clean up package directory if it still exists
if [[ -d "$NPM_GLOBAL_DIR/$PACKAGE" ]]; then
  echo "🗑️ Removing leftover package directory..."
  sudo rm -rf "$NPM_GLOBAL_DIR/$PACKAGE"
fi

# Step 5: Clear npm cache
echo "🧺 Cleaning npm cache..."
npm cache clean --force >/dev/null 2>&1

# Step 6: Verify removal
echo "🔎 Verifying cleanup..."
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
  echo "❌ Issues found:"
  for ISSUE in "${ISSUES[@]}"; do
    echo "   - $ISSUE"
  done
  echo "You may need to remove these manually or check your PATH."
  exit 1
else
  echo "✅ $PACKAGE fully removed from your system!"
fi

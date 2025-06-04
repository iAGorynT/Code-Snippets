#!/bin/zsh

# Set strict error handling
set -euo pipefail

# Script configuration
readonly SHELL_DIR="$HOME/ShellScripts"
readonly PYCODE_DIR="$HOME/PythonCode"
readonly TARGET_BASE_DIR="$HOME/Documents/GitHub/Code-Snippets"
readonly DOTFILES=(
    ".gvimrc"
    ".vimrc"
    ".zshrc"
)
readonly BREWFILES=(
    "Brewfile"
)

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { echo "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

function sync_shellscripts() {
    info_printf "Syncing ShellScripts..."
    rsync -avhl --delete --exclude '.DS_Store' \
        "$SHELL_DIR/" \
        "$TARGET_BASE_DIR/ShellScripts"
}

function sync_pythoncode () {
    info_printf "Syncing PythonCode..."
    rsync -avhl --delete --exclude '.DS_Store' \
        "$PYCODE_DIR/" \
        "$TARGET_BASE_DIR/PythonCode"
}

function sync_dotfiles() {
    info_printf "Syncing DotFiles..."
    for dotfile in "${DOTFILES[@]}"; do
        rsync -avhl --delete \
            "$HOME/$dotfile" \
            "$TARGET_BASE_DIR/DotFiles"
    done
}

function sync_brewfiles() {
    info_printf "Syncing BrewFiles..."
    for brewfile in "${BREWFILES[@]}"; do
        rsync -avhl --delete \
            "$HOME/$brewfile" \
            "$TARGET_BASE_DIR/HomeBrew"
    done
}

function check_macvim() {
    if pgrep -i "MacVim" >/dev/null; then
        error_printf "MacVim is Running! Quit and Rerun Devsync..." true
    fi
}

function main() {
    clear
    format_printf "Dev to GitHub Sync Starting..." "yellow" "bold"
    echo

    check_macvim
    sync_shellscripts
    echo
    sync_pythoncode
    echo
    sync_dotfiles
    echo
    sync_brewfiles
    echo

    success_printf "Sync Completed!"
}

# Execute main function if script is being run directly (not sourced)
if [[ ! "$ZSH_EVAL_CONTEXT" =~ :file$ ]]; then
    main
fi

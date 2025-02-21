#!/bin/zsh

# Set strict error handling
set -euo pipefail

# Script configuration
readonly SOURCE_DIR="$HOME/ShellScripts"
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
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatEcho.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    echo "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

function sync_shellscripts() {
    info_echo "Syncing ShellScripts..."
    rsync -avhl --delete --exclude '.DS_Store' \
        "$SOURCE_DIR/" \
        "$TARGET_BASE_DIR/ShellScripts"
}

function sync_dotfiles() {
    info_echo "Syncing DotFiles..."
    for dotfile in "${DOTFILES[@]}"; do
        rsync -avhl --delete \
            "$HOME/$dotfile" \
            "$TARGET_BASE_DIR/DotFiles"
    done
}

function sync_brewfiles() {
    info_echo "Syncing BrewFiles..."
    for brewfile in "${BREWFILES[@]}"; do
        rsync -avhl --delete \
            "$HOME/$brewfile" \
            "$TARGET_BASE_DIR/HomeBrew"
    done
}

function check_macvim() {
    if pgrep -i "MacVim" >/dev/null; then
        error_echo "MacVim is Running! Quit and Rerun Devsync..." true
    fi
}

function main() {
    clear
    format_echo "Dev to GitHub Sync Starting..." "yellow" "bold"
    echo

    check_macvim
    sync_shellscripts
    echo
    sync_dotfiles
    echo
    sync_brewfiles
    echo

    success_echo "Sync Completed!"
}

# Execute main function if script is being run directly (not sourced)
if [[ ! "$ZSH_EVAL_CONTEXT" =~ :file$ ]]; then
    main
fi

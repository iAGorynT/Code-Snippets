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

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatEcho.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    echo "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

function sync_shellscripts() {
    info_echo "Syncing ShellScripts..."
    rsync -avhl --delete \
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

    success_echo "Sync Completed!"
}

# Execute main function if script is being run directly (not sourced)
if [[ ! "$ZSH_EVAL_CONTEXT" =~ :file$ ]]; then
    main
fi

#!/bin/zsh

# Set strict error handling for the script itself, but handle rsync errors gracefully
set -uo pipefail

# Script configuration
readonly SHELL_DIR="$HOME/ShellScripts"
readonly PYCODE_DIR="$HOME/PythonCode"
readonly MCPSERVER_DIR="$HOME/mcp-servers"
readonly LAUNCHD_DIR="$HOME/Launchd"
readonly GHS_BASE_DIR="$HOME/Documents/GitHub/Code-Snippets"
readonly GHA_BASE_DIR="$HOME/Documents/GitHub/Brew-Autoupdate"
readonly DOTFILES=(
    ".gvimrc"
    ".vimrc"
    ".zshrc"
    ".zshenv"
)
readonly BREWFILES=(
    "Brewfile"
)
readonly AUTOSHELLFILES=(
    "BrewautoInstaller.sh"
    "Brewautom2.sh"
    "BrewitLaunchd.sh"
    "FLibFormatPrintf.sh"
)
readonly AUTOLAUNCHDFILES=(
    "Launchd.plist"
)

# Track sync failures
SYNC_FAILURES=0

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Helper function to safely execute rsync with error handling
function safe_rsync() {
    local source="$1"
    local destination="$2"
    shift 2
    local rsync_options=("$@")
    
    if ! rsync "${rsync_options[@]}" "$source" "$destination"; then
        error_printf "Failed to sync: $source -> $destination"
        ((SYNC_FAILURES++))
        return 1
    fi
    return 0
}

# Helper function to check if directory exists
function check_directory() {
    local dir="$1"
    local description="$2"
    
    if [[ ! -d "$dir" ]]; then
        error_printf "$description directory not found: $dir - skipping"
        return 1
    fi
    return 0
}

# Code-Snippets Sync Functions 

function sync_ghs_shellscripts() {
    info_printf "Syncing ShellScripts..."
    
    if ! check_directory "$SHELL_DIR" "ShellScripts"; then
        return 1
    fi
    
    safe_rsync "$SHELL_DIR/" "$GHS_BASE_DIR/ShellScripts" -avhl --delete --exclude '.DS_Store'
}

function sync_pythoncode() {
    info_printf "Syncing PythonCode..."
    
    if ! check_directory "$PYCODE_DIR" "PythonCode"; then
        return 1
    fi
    
    safe_rsync "$PYCODE_DIR/" "$GHS_BASE_DIR/PythonCode" -avhl --delete --exclude '.DS_Store'
}

function sync_mcpservers() {
    info_printf "Syncing MCPServers..."
    
    if ! check_directory "$MCPSERVER_DIR" "MCPServers"; then
        return 1
    fi
    
    safe_rsync "$MCPSERVER_DIR/" "$GHS_BASE_DIR/mcp-servers" -avhl --delete --exclude '.DS_Store' --exclude 'node_modules' --exclude '*backup*'
}

function sync_dotfiles() {
    info_printf "Syncing DotFiles..."
    
    local failed_files=()
    for dotfile in "${DOTFILES[@]}"; do
        if [[ ! -f "$HOME/$dotfile" ]]; then
            error_printf "Dotfile not found: $HOME/$dotfile - skipping"
            failed_files+=("$dotfile")
            continue
        fi
        
        if ! safe_rsync "$HOME/$dotfile" "$GHS_BASE_DIR/DotFiles" -avhl --exclude '.DS_Store'; then
            failed_files+=("$dotfile")
        fi
    done
    
    if [[ ${#failed_files[@]} -gt 0 ]]; then
        error_printf "Failed to sync dotfiles: ${failed_files[*]}"
        return 1
    fi
    return 0
}

function sync_brewfiles() {
    info_printf "Syncing BrewFiles..."
    
    local failed_files=()
    for brewfile in "${BREWFILES[@]}"; do
        if [[ ! -f "$HOME/$brewfile" ]]; then
            error_printf "Brewfile not found: $HOME/$brewfile - skipping"
            failed_files+=("$brewfile")
            continue
        fi
        
        if ! safe_rsync "$HOME/$brewfile" "$GHS_BASE_DIR/HomeBrew" -avhl --exclude '.DS_Store'; then
            failed_files+=("$brewfile")
        fi
    done
    
    if [[ ${#failed_files[@]} -gt 0 ]]; then
        error_printf "Failed to sync brewfiles: ${failed_files[*]}"
        return 1
    fi
    return 0
}

function check_macvim() {
    if pgrep -i "MacVim" >/dev/null; then
        error_printf "MacVim is Running! Quit and Rerun Devsync..." true
    fi
}

# Brew-Autoupdate Sync Functions

function sync_gha_shellscripts() {
    info_printf "Syncing ShellScripts..."
    
    if ! check_directory "$SHELL_DIR" "ShellScripts"; then
        return 1
    fi
    
    local failed_files=()
    for autoshellfile in "${AUTOSHELLFILES[@]}"; do
        if [[ ! -f "$SHELL_DIR/$autoshellfile" ]]; then
            error_printf "Auto shell file not found: $SHELL_DIR/$autoshellfile - skipping"
            failed_files+=("$autoshellfile")
            continue
        fi
        
        if ! safe_rsync "$SHELL_DIR/$autoshellfile" "$GHA_BASE_DIR/bin" -avhl --exclude '.DS_Store'; then
            failed_files+=("$autoshellfile")
        fi
    done
    
    if [[ ${#failed_files[@]} -gt 0 ]]; then
        error_printf "Failed to sync auto shell files: ${failed_files[*]}"
        return 1
    fi
    return 0
}

function sync_launchdfiles() {
    info_printf "Syncing LaunchdFiles..."
    
    if ! check_directory "$LAUNCHD_DIR" "Launchd"; then
        return 1
    fi
    
    local failed_files=()
    for autolaunchdfile in "${AUTOLAUNCHDFILES[@]}"; do
        if [[ ! -f "$LAUNCHD_DIR/$autolaunchdfile" ]]; then
            error_printf "Auto launchd file not found: $LAUNCHD_DIR/$autolaunchdfile - skipping"
            failed_files+=("$autolaunchdfile")
            continue
        fi
        
        if ! safe_rsync "$LAUNCHD_DIR/$autolaunchdfile" "$GHA_BASE_DIR/Launchd" -avhl --exclude '.DS_Store'; then
            failed_files+=("$autolaunchdfile")
        fi
    done
    
    if [[ ${#failed_files[@]} -gt 0 ]]; then
        error_printf "Failed to sync auto launchd files: ${failed_files[*]}"
        return 1
    fi
    return 0
}

function main() {
    clear
    format_printf "Dev to GitHub Sync Starting (Code-Snippets)..." "yellow" "bold"
    printf "\n"

    check_macvim
    
    sync_ghs_shellscripts
    printf "\n"
    sync_pythoncode
    printf "\n"
    sync_mcpservers
    printf "\n"
    sync_dotfiles
    printf "\n"
    sync_brewfiles
    printf "\n"

    printf "\n"
    printf "\033[1;36mPress any key to continue to Brew-Autoupdate sync...\033[0m"
    read -k1 -s

    clear
    format_printf "Dev to GitHub Sync Starting (Brew-Autoupdate)..." "yellow" "bold"
    printf "\n"

    sync_gha_shellscripts
    printf "\n"
    sync_launchdfiles
    printf "\n"

    if [[ $SYNC_FAILURES -eq 0 ]]; then
        success_printf "Sync Completed!"
    else
        error_printf "Sync Completed with $SYNC_FAILURES failures - check output above"
        exit 1
    fi
}

# Execute main function if script is being run directly (not sourced)
if [[ ! "$ZSH_EVAL_CONTEXT" =~ :file$ ]]; then
    main
fi

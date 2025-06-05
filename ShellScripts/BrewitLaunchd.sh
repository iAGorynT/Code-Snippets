#!/bin/zsh

# This is a special Launchd Version of Brewit.sh
# Place this file in ~/Library/LaunchAgents folder for Homebrew auto updating
# When changes are made, be sure to Unload / Load new file into Launchd

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2; exit 1; }
source "$FORMAT_LIBRARY"

format_printf "Brew Update, Upgrade, and Cleanup..."
format_printf "$(date)"
printf "\n"

# HomeBrew Update
format_printf "HomeBrew Update..." "none" "brewl"
printf "\n"
brew update
brew upgrade

# Cask Upgrade
format_printf "Cask Upgrade..." "none" "brewl"
printf "\n"
brew upgrade --cask --greedy

# Create temporary Brewfile
format_printf "Creating temporary Brewfile..." "none" "brewl"
printf "\n"
cd
brew bundle dump --file=Brewfile.new

# Check if previous Brewfile exists
if [[ -f Brewfile ]]; then
    format_printf "Comparing with existing Brewfile..." "none" "brewl"
    
    # Compare files, ignoring whitespace
    if diff -w Brewfile Brewfile.new > /dev/null; then
        format_printf "No changes detected. Keeping existing Brewfile." "none" "brewl"
        rm Brewfile.new
    else
        format_printf "Changes detected. Updating Brewfile..." "none" "brewl"
        mv Brewfile Brewfile.backup
        mv Brewfile.new Brewfile
        chmod 644 Brewfile
        format_printf "Backup of previous Brewfile created as: Brewfile.backup"
    fi
else
    format_printf "No existing Brewfile found. Creating new one..." "none" "brewl"
    mv Brewfile.new Brewfile
    chmod 644 Brewfile
fi

format_printf "Current Brewfile location: $(pwd)"
ls -al Brewfile
printf "\n"

# HomeBrew Cleanup
format_printf "HomeBrew Cleanup..." "none" "brewl"
printf "\n"
brew autoremove
brew cleanup
printf "\n"
format_printf "Installed Apps..." "none" "brewl"
brew list -1

printf "\n"
format_printf "Brew Update, Upgrade, and Cleanup Completed!"
printf "\n"

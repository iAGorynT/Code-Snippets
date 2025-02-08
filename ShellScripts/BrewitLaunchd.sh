#!/bin/zsh

# This is a special Launchd Version of Brewit.sh
# Place this file in ~/Library/LaunchAgents folder for Homebrew auto updating
# When changes are made, be sure to Unload / Load new file into Launchd

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatEcho.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    echo "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

echo "Brew Update, Upgrade, and Cleanup..."
echo $(date)
echo " "

# HomeBrew Update
format_echo "HomeBrew Update..." "none" "brewl"
echo " "
brew update
brew upgrade

# Cask Upgrade
format_echo "Cask Upgrade..." "none" "brewl"
echo " "
brew upgrade --cask --greedy

# Create temporary Brewfile
format_echo "Creating temporary Brewfile..." "none" "brewl"
echo " "
cd
brew bundle dump --file=Brewfile.new

# Check if previous Brewfile exists
if [[ -f Brewfile ]]; then
    format_echo "Comparing with existing Brewfile..." "none" "brewl"
    
    # Compare files, ignoring whitespace
    if diff -w Brewfile Brewfile.new > /dev/null; then
        format_echo "No changes detected. Keeping existing Brewfile." "none" "brewl"
        rm Brewfile.new
    else
        format_echo "Changes detected. Updating Brewfile..." "none" "brewl"
        mv Brewfile Brewfile.backup
        mv Brewfile.new Brewfile
        chmod 644 Brewfile
        echo "Backup of previous Brewfile created as: Brewfile.backup"
    fi
else
    format_echo "No existing Brewfile found. Creating new one..." "none" "brewl"
    mv Brewfile.new Brewfile
    chmod 644 Brewfile
fi

echo "Current Brewfile location: $(pwd)"
ls -al Brewfile
echo " "

# HomeBrew Cleanup
format_echo "HomeBrew Cleanup..." "none" "brewl"
echo " "
brew autoremove
brew cleanup
echo " "
format_echo "Installed Apps..." "none" "brewl"
brew list -1

echo " "
echo "Brew Update, Upgrade, and Cleanup Completed!"
echo " "

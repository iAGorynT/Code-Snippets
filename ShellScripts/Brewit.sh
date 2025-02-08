#!/bin/zsh

# Update BrewitLaunchd.sh with changes when necessary.

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatEcho.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    echo "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

clear
format_echo "Brew Update, Upgrade, and Cleanup..." "yellow" "bold"
echo " "

# HomeBrew Update
format_echo "HomeBrew Update..." "none" "brew"
echo " "
brew update
brew upgrade

# Cask Upgrade
format_echo "Cask Upgrade..." "none" "brew"
echo " "
brew upgrade --cask --greedy

# Create temporary Brewfile
format_echo "Creating temporary Brewfile..." "none" "brew"
echo " "
cd
brew bundle dump --file=Brewfile.new

# Check if previous Brewfile exists
if [[ -f Brewfile ]]; then
    format_echo "Comparing with existing Brewfile..." "none" "brew"
    
    # Compare files, ignoring whitespace
    if diff -w Brewfile Brewfile.new > /dev/null; then
        format_echo "No changes detected. Keeping existing Brewfile." "none" "brew"
        rm Brewfile.new
    else
        format_echo "Changes detected. Updating Brewfile..." "none" "brew"
        mv Brewfile Brewfile.backup
        mv Brewfile.new Brewfile
        chmod 644 Brewfile
        echo "Backup of previous Brewfile created as: Brewfile.backup"
    fi
else
    format_echo "No existing Brewfile found. Creating new one..." "none" "brew"
    mv Brewfile.new Brewfile
    chmod 644 Brewfile
fi

echo "Current Brewfile location: $(pwd)"
ls -al Brewfile
echo " "

# HomeBrew Cleanup
format_echo "HomeBrew Cleanup..." "none" "brew"
echo " "
brew autoremove
brew cleanup
brew list

echo " "
success_echo "Brew Update, Upgrade, and Cleanup Completed!"
echo " "

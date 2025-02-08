#!/bin/zsh

# This is a special Launchd Version of Brewit.sh
# Place this file in ~/Library/LaunchAgents folder for Homebrew auto updating
# When changes are made, be sure to Unload / Load new file into Launchd

echo "Brew Update, Upgrade, and Cleanup..."
echo $(date)
echo " "

# HomeBrew Update
echo "HomeBrew Update..."
echo " "
brew update
brew upgrade

# Cask Upgrade
echo "Cask Upgrade..."
echo " "
brew upgrade --cask --greedy

# Create temporary Brewfile
echo "Creating temporary Brewfile..."
echo " "
cd
brew bundle dump --file=Brewfile.new

# Check if previous Brewfile exists
if [[ -f Brewfile ]]; then
    echo "Comparing with existing Brewfile..."
    
    # Compare files, ignoring whitespace
    if diff -w Brewfile Brewfile.new > /dev/null; then
        echo "No changes detected. Keeping existing Brewfile."
        rm Brewfile.new
    else
        echo "Changes detected. Updating Brewfile..."
        mv Brewfile Brewfile.backup
        mv Brewfile.new Brewfile
        chmod 644 Brewfile
        echo "Backup of previous Brewfile created as: Brewfile.backup"
    fi
else
    echo "No existing Brewfile found. Creating new one..."
    mv Brewfile.new Brewfile
    chmod 644 Brewfile
fi

echo "Current Brewfile location: $(pwd)"
ls -al Brewfile
echo " "

# HomeBrew Cleanup
echo "HomeBrew Cleanup..."
echo " "
brew autoremove
brew cleanup
echo " "
echo "Installed Apps..."
brew list -1

echo " "
echo "Brew Update, Upgrade, and Cleanup Completed!"
echo " "

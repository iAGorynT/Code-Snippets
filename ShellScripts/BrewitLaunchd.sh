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

# Create New Brewfile
echo "Creating New Brewfile..."
echo " "
cd
brew bundle dump --force
chmod 644 Brewfile
echo "Brewfile created in: $(pwd)"
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

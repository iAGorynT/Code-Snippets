#!/bin/zsh

# Update BrewitLaunchd.sh with changes when necessary.

# Activate Function Library
source $HOME/ShellScripts/FLibFormatEcho.sh

clear
echo "Brew Update, Upgrade, and Cleanup..."
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

# Create New Brewfile
format_echo "Creating New Brewfile..." "none" "brew"
echo " "
cd
brew bundle dump --force
chmod 644 Brewfile
echo "Brewfile created in: $(pwd)"
ls -al Brewfile
echo " "

# HomeBrew Cleanup
format_echo "HomeBrew Cleanup..." "none" "brew"
echo " "
brew autoremove
brew cleanup
brew list

echo " "
echo "Brew Update, Upgrade, and Cleanup Completed!"
echo " "

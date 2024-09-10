#!/bin/zsh

# Activate Function Library
source $HOME/ShellScripts/FunctionLib.sh

clear
echo "Brew Update, Upgrade, and Cleanup..."
echo " "

# HomeBrew Update
format_echo "HomeBrew Update..." "brew" 1
echo " "
brew update
brew upgrade

# Cask Upgrade
format_echo "Cask Upgrade..." "brew" 1
echo " "
brew upgrade --cask --greedy

# Create New Brewfile
format_echo "Creating New Brewfile..." "brew" 1
echo " "
cd
brew bundle dump --force
chmod 644 Brewfile
echo "Brewfile created in: $(pwd)"
ls -al Brewfile
echo " "

# HomeBrew Cleanup
format_echo "HomeBrew Cleanup..." "brew" 1
echo " "
brew autoremove
brew cleanup
brew list

echo " "
echo "Brew Update, Upgrade, and Cleanup Completed!"
echo " "

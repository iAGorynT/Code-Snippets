#!/bin/zsh

# Activate Function Library
source $HOME/ShellScripts/FunctionLib.sh

clear
echo "Brew Update, Upgrade, and Cleanup..."
echo " "

# HomeBrew Update
brew_echo "HomeBrew Update..." 1
echo " "
brew update
brew upgrade

# Cask Upgrade
brew_echo "Cask Upgrade..." 1
echo " "
brew upgrade --cask --greedy

# Create New Brewfile
brew_echo "Creating New Brewfile..." 1
echo " "
cd
brew bundle dump --force
chmod 644 Brewfile
echo "Brewfile created in: $(pwd)"
ls -al Brewfile
echo " "

# HomeBrew Cleanup
brew_echo "HomeBrew Cleanup..." 1
echo " "
brew autoremove
brew cleanup
brew list

echo " "
echo "Brew Update, Upgrade, and Cleanup Completed!"
echo " "

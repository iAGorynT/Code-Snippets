#!/bin/zsh

clear
echo "Brew Update, Upgrade, and Cleanup..."
echo " "

# HomeBrew Update
echo "*** HomeBrew Update..."
echo " "
brew update
brew upgrade

# Cask Upgrade
echo "*** Cask Upgrade..."
echo " "
brew upgrade --cask --greedy

# Create New Brewfile
echo "*** Creating New Brewfile..."
echo " "
cd
brew bundle dump --force
chmod 644 Brewfile
echo "Brewfile created in: $(pwd)"
ls -al Brewfile

# HomeBrew Cleanup
echo "*** HomeBrew Cleanup..."
echo " "
brew autoremove
brew cleanup
brew list

echo " "
echo "Brew Update, Upgrade, and Cleanup Completed!"
echo " "

#!/bin/zsh

clear
echo "Brew Update, Upgrade, and Cleanup..."
echo " "

# HomeBrew Update
echo "***HobeBrew Update..."
echo " "
brew update
brew upgrade

# Cask Upgrade
echo "***Cask Upgrade..."
echo " "
brew upgrade --cask --greedy

# HomeBrew Cleanup
echo "***HomeBrew Cleanup..."
echo " "
brew autoremove
brew cleanup
brew list

echo " "
echo "Brew Update, Upgrade, and Cleanup Completed!"
echo " "

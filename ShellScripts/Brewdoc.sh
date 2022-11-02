#!/bin/zsh

clear
echo "Brew Doctor Troubleshooting..."
echo " "

# HomeBrew Update 1/2
echo "*** HomeBrew Update 1/2..."
echo " "
brew update
echo " "

# HomeBrew Update 2/2
echo "*** HomeBrew Update 2/2..."
echo " "
brew update
echo " "

# Brew Doctor
echo "*** Brew Doctor..."
echo " "
brew doctor

echo " "
echo "Brew Doctor Complete!"
echo " "

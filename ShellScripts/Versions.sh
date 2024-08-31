#!/bin/zsh

# Display Software Versions
clear
echo "Software Versions..."
echo

# Bash
echo "Bash: $(bash --version)" | grep -e 'version '

# Homebrew
echo "Homebrew: $(brew --version)"

# Homebrew Autoupdate
echo "Homebrew Autoupdate: $(brew autoupdate version | grep -e 'Version')" # Exclude Change Log

# Java
echo
echo "Java:"
java --version
echo

# jq
echo "jq JSON processor: $(jq -V)"

# MacVim
echo
echo "MacVim:"
mver=$(mvim --version | grep -e 'VIM - Vi IMproved' -e 'Included patches')
echo "Version: $mver"
echo "Autoload..."
ls -1 ~/.vim/autoload
echo "Plugins..."
ls -1 ~/.vim/plugged
echo "Colors..."
ls -1 ~/.vim/colors
echo

# Mosh
mosh --version | grep -e 'mosh '

# SSH
# Had to run ssh command and pipe it to echo -n (no new line)
# in order to get results on one line.  Just trying to echo
# produced 2 line output.
ssh -V | echo -n "OpenSSH: "

# OpenSSL
echo "OpenSSL: $(openssl version)"

# Python
echo "Python3: $(python3 --version)"

# XCode Command Line Tools
echo
echo "Xcode Command Line Tools:"
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
echo

# Zsh
echo "Zsh: $(zsh --version)"

echo


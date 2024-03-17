#!/bin/zsh

# Display Software Versions
clear
echo "Software Versions..."
echo

# Bash
echo "Bash: $(bash --version)" | grep -e 'version '

# Zsh
echo "Zsh: $(zsh --version)"

# SSH
# Had to run ssh command and pipe it to echo -n (no new line)
# in order to get results on one line.  Just trying to echo
# produced 2 line output.
ssh -V | echo -n "OpenSSH: "

# OpenSSL
echo "OpenSSL: $(openssl version)"

# jq
echo "jq JSON processor: $(jq -V)"

# Python
echo "Python3: $(python3 --version)"

# Mosh
mosh --version | grep -e 'mosh '

# macVim
mver=$(mvim --version | grep -e 'VIM - Vi IMproved' -e 'Included patches')
echo "macVim Version: $mver"

# Homebrew
echo "Homebrew: $(brew -v)"

# Homebrew Autoupdate
echo "Homebrew Autoupdate: $(brew autoupdate version | grep -e 'Version')" # Exclude Change Log

# XCode Command Line Tools
echo
echo "Xcode Command Line Tools:"
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
echo

# Java
echo "Java:"
java --version
echo


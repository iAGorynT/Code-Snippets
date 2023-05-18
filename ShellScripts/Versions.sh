#!/bin/bash

# Display Software Versions
clear
echo "Software Versions..."
echo

# Bash
echo "Bash: $BASH_VERSION"

# Zsh
echo "Zsh: $(zsh --version)"

# SSH
# Had to run ssh command and pipe it to echo -n (no new line)
# in order to get results on one line.  Just trying to echo
# produced 2 line output.
ssh -V | echo -n "OpenSSH: "

# OpenSSL
echo "OpenSSL: $(openssl version)"

# Homebrew
echo "Homebrew: $(brew -v)"

# XCode Command Line Tools
echo
echo "Xcode Command Line Tools:"
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
echo

# Java
echo "Java:"
java --version
echo


#!/bin/zsh

# Activate Function Library
source $HOME/ShellScripts/FLibFormatEcho.sh

# Display Software Versions
clear
echo "Software Versions..."
echo

# Bash
echo "Bash: $(bash --version)" | grep -e 'version '

# Homebrew
echo "Homebrew: $(brew --version)"

# Homebrew Autoupdate
# echo "Homebrew Autoupdate: $(brew autoupdate version | grep -e 'Version')" # Exclude Change Log

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
format_echo "Autoload" "none" "underline"
ls -1 ~/.vim/autoload
format_echo "Plugins" "none" "underline"
ls --color=never -1 ~/.vim/plugged
format_echo "Colors" "none" "underline"
ls -1 ~/.vim/colors
echo

# SSH
# Had to run ssh command and pipe it to echo -n (no new line)
# in order to get results on one line.  Just trying to echo
# produced 2 line output.
ssh -V | echo -n "OpenSSH: "

# OpenSSL
echo "OpenSSL: $(openssl version)"

# Python
echo "Python3: $(python3 --version)"

# Rosetta2
# Check for the presence of the Rosetta 2 installation receipt
if command -v lsbom >/dev/null && lsbom -f /Library/Apple/System/Library/Receipts/com.apple.pkg.RosettaUpdateAuto.bom >/dev/null 2>&1; then
    echo "Rosetta2: Installed"
else
    echo "Rosetta2: NOT installed"
fi

# XCode Command Line Tools
echo
echo "Xcode Command Line Tools:"
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
echo

# Zsh
echo "Zsh: $(zsh --version)"

echo


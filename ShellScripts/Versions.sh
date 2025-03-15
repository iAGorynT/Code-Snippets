#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatEcho.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    echo "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

# Display Software Versions
clear
format_echo "Software Versions..." yellow bold
echo

# Bash
echo "Bash: $(bash --version)" | grep -e 'version '

# GitHub
echo
info_echo "GitHub"
# Git
echo "Git: $(git --version)"
# Github CLI
echo "GitHub CLI: $(gh --version)" | grep -e 'version '
echo

# Homebrew
echo "Homebrew: $(brew --version)"

# Homebrew Autoupdate
# echo "Homebrew Autoupdate: $(brew autoupdate version | grep -e 'Version')" # Exclude Change Log

# Java
echo
info_echo "Java:"
java --version
echo

# jq
echo "jq JSON processor: $(jq -V)"

# MacVim
echo
info_echo "MacVim:"
mver=$(mvim --version | grep -e 'VIM - Vi IMproved' -e 'Included patches')
echo "Version: $mver"
format_echo "Autoload" "white" "underline"
ls -1 ~/.vim/autoload
format_echo "Plugins" "white" "underline"
ls --color=never -1 ~/.vim/plugged
format_echo "Colors" "white" "underline"
ls -1 ~/.vim/colors
echo

# Node / Npm
echo "Node: $(node --version)"
echo "Npm: $(npm --version)"

# Oath Toolkit
echo
echo "Oath Toolkit: $(oathtool --version | grep -e 'Toolkit')"
echo

# SSH
# Had to run ssh command and pipe it to echo -n (no new line)
# in order to get results on one line.  Just trying to echo
# produced 2 line output.
ssh -V | echo -n "OpenSSH: "

# OpenSSL
echo "OpenSSL: $(openssl version)"

# Python
echo
info_echo "Python3:"
python3 --version
python3 -m pip --version | sed 's/\(.*\)from.*/\1/'
pyenv --version
echo

# Rosetta2
# Check for the presence of the Rosetta 2 installation receipt
if command -v lsbom >/dev/null && lsbom -f /Library/Apple/System/Library/Receipts/com.apple.pkg.RosettaUpdateAuto.bom >/dev/null 2>&1; then
    info_echo "Rosetta2: Installed"
else
    error_echo "Rosetta2: NOT installed"
fi

# XCode Command Line Tools
echo
info_echo "Xcode Command Line Tools:"
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
echo

# Zsh
echo "Zsh: $(zsh --version)"

# echo


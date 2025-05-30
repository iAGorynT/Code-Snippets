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
info_echo "GitHub:"
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
# Get current installed Java version (Zulu style)
# Handle both formats: Zulu24.30.11 and Zulu24.30+11-CA
java_version_output=$(java -version 2>&1)
if echo "$java_version_output" | grep -q "Zulu"; then
    # Extract the Zulu version pattern and clean it up
    current_zulu_version=$(echo "$java_version_output" | grep -oE 'Zulu[0-9]+\.[0-9]+[+\.][0-9]+' | head -1 | sed -E 's/Zulu([0-9]+\.[0-9]+)[+\.]([0-9]+).*/\1.\2/')
else
    current_zulu_version=""
fi
# Check if we found a Zulu version
if [[ -z "$current_zulu_version" ]]; then
    warning_echo "Current installed Zulu version: Not found (or not Zulu JDK)"
else
    echo "Zulu $current_zulu_version"
fi
# Fetch list of all Zulu .dmg files from CDN
file_list=$(curl -s https://cdn.azul.com/zulu/bin/)
# Check if curl was successful
if [[ $? -ne 0 || -z "$file_list" ]]; then
    error_echo "Failed to fetch version information from Azul CDN" true
fi
# Extract macOS .dmg filenames with Zulu and Java 11+
dmg_links=(${(@f)$(grep -Eo 'zulu([0-9]+\.[0-9]+\.[0-9]+)-ca-jdk(1[1-9]|2[0-9])[0-9\.\-]*-macosx_[^"]+\.dmg' <<< "$file_list")})
# Remove duplicate links and sort (reverse natural sort)
unique_dmg_links=(${(u)dmg_links[@]})
sorted=(${(On)unique_dmg_links[@]})
# Extract latest Zulu version
latest_zulu_version=""
for link in "${sorted[@]}"; do
    if [[ "$link" =~ zulu([0-9]+\.[0-9]+\.[0-9]+)-ca ]]; then
        latest_zulu_version="${match[1]}"
        break
    fi
done
if [[ -z "$latest_zulu_version" ]]; then
    error_echo "Could not determine latest Zulu version" true
fi
# Now list all links that match this latest version
info_echo "Latest Zulu version for Mac: $latest_zulu_version"
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
# Get the latest Python version from GitHub
# This approach uses the GitHub API to check Python tags
# Get all version tags and find the highest non-alpha/beta version
latest_tag=$(curl -s https://api.github.com/repos/python/cpython/tags | 
	grep -o '"name": "v[0-9]\+\.[0-9]\+\.[0-9]\+"' | 
	sed 's/"name": "v//' | 
	sed 's/"//' | 
	sort -V | 
	tail -1)
info_echo "Latest Python version for Mac: $latest_tag"
pyenv --version
python3 -m pip --version | sed 's/\(.*\)from.*/\1/'
echo
info_echo "Pip Installed Packages:"
pip list --format=columns
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


#!/bin/zsh
# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"

[[ -f "$FORMAT_LIBRARY" ]] || { echo "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Display Software Versions
clear
format_printf "Software Versions..." yellow bold
printf "\n"

# Bash
printf "Bash: %s\n" "$(bash --version)" | grep -e 'version '

# GitHub
printf "\n"
info_printf "GitHub:"
# Git
printf "Git: %s\n" "$(git --version)"
# Github CLI
printf "GitHub CLI: %s\n" "$(gh --version)" | grep -e 'version '
# Github CLI Copilot Extension
printf "GitHub CLI Copilot: %s\n" "$(gh copilot --version)"
printf "\n"

# Homebrew
printf "Homebrew: %s\n" "$(brew --version)"

# Homebrew Autoupdate
# echo "Homebrew Autoupdate: $(brew autoupdate version | grep -e 'Version')" # Exclude Change Log

# Java
printf "\n"
info_printf "Java:"
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
    warning_printf "Current installed Zulu version: Not found (or not Zulu JDK)"
else
    printf "Zulu %s\n" "$current_zulu_version"
fi
# Fetch list of all Zulu .dmg files from CDN
file_list=$(curl -s https://cdn.azul.com/zulu/bin/)
# Check if curl was successful
if [[ $? -ne 0 || -z "$file_list" ]]; then
    error_printf "Failed to fetch version information from Azul CDN" true
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
    error_printf "Could not determine latest Zulu version" true
fi
# Now list all links that match this latest version
info_printf "Latest Zulu version for Mac: $latest_zulu_version"
printf "\n"

# jq
printf "jq JSON processor: %s\n" "$(jq -V)"

# MacVim
printf "\n"
info_printf "MacVim:"
mver=$(mvim --version | grep -e 'VIM - Vi IMproved' -e 'Included patches')
printf "Version: %s\n" "$mver"
format_printf "Autoload" "white" "underline"
ls -1 ~/.vim/autoload
format_printf "Plugins" "white" "underline"
ls --color=never -1 ~/.vim/plugged
format_printf "Colors" "white" "underline"
ls -1 ~/.vim/colors
printf "\n"

# Node / Npm
printf "Node: %s\n" "$(node --version)"
printf "Npm: %s\n" "$(npm --version)"
printf "\n"

# SSH
# Had to run ssh command and pipe it to printf (no new line)
# in order to get results on one line.  Just trying to printf
# produced 2 line output.
ssh -V 2>&1 | { read line; printf "OpenSSH: %s\n" "$line"; }

# OpenSSL
printf "OpenSSL: %s\n" "$(openssl version)"

# Python
printf "\n"
info_printf "Python3:"
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
info_printf "Latest Python version for Mac: $latest_tag"
pyenv --version
python3 -m pip --version | sed 's/\(.*\)from.*/\1/'
printf "\n"
info_printf "Pip Installed Packages:"
pip list --format=columns
printf "\n"

# Rosetta2
# Check for the presence of the Rosetta 2 installation receipt
if command -v lsbom >/dev/null && lsbom -f /Library/Apple/System/Library/Receipts/com.apple.pkg.RosettaUpdateAuto.bom >/dev/null 2>&1; then
    info_printf "Rosetta2: Installed"
else
    error_printf "Rosetta2: NOT installed"
fi

# XCode Command Line Tools
printf "\n"
info_printf "Xcode Command Line Tools:"
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
printf "\n"

# Zsh
printf "Zsh: %s\n" "$(zsh --version)"


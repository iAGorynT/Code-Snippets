#!/bin/zsh
# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"

[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Helper function to get tool version with existence check
get_version() {
    local cmd=$1
    local filter=$2
    local description=$3
    local version_args=${4:-"--version"}
    
    if command -v "$cmd" >/dev/null 2>&1; then
        local version_output
        if [[ -n "$filter" ]]; then
            version_output=$("$cmd" $version_args 2>&1 | grep -e "$filter" | head -1)
        else
            version_output=$("$cmd" $version_args 2>&1 | head -1)
        fi
        printf "%s: %s\n" "$description" "$version_output"
    else
        warning_printf "$description: Not installed"
    fi
}

# Display Software Versions
clear
format_printf "Software Versions..." yellow bold
printf "\n"

# GitHub
info_printf "GitHub:"
get_version "git" "git version" "Git"
get_version "gh" "version" "GitHub CLI" "--version"
printf "\n"

# Homebrew
get_version "brew" "Homebrew" "Homebrew"

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
# Fetch list of all Zulu .dmg files from CDN with timeout
file_list=$(curl -s --max-time 30 https://cdn.azul.com/zulu/bin/)
# Check if curl was successful
if [[ $? -ne 0 || -z "$file_list" ]]; then
    warning_printf "Failed to fetch version information from Azul CDN - skipping latest version check"
    # Set default values to continue script execution
    latest_zulu_version="Unknown"
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
    warning_printf "Could not determine latest Zulu version"
    latest_zulu_version="Unknown"
fi
# Now list all links that match this latest version
info_printf "Latest Zulu version for Mac: $latest_zulu_version"
printf "\n"

# jq
get_version "jq" "" "jq JSON processor" "-V"

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
get_version "node" "" "Node"
get_version "npm" "" "Npm"
printf "\n"

# OpenCode
get_version "opencode" "" "OpenCode" 
printf "\n"

# SSH
# Had to run ssh command and pipe it to printf (no new line)
# in order to get results on one line.  Just trying to printf
# produced 2 line output.
ssh -V 2>&1 | { read line; printf "OpenSSH: %s\n" "$line"; }

# OpenSSL
printf "OpenSSL: %s\n" "$(openssl version)"
printf "\n"

# Rosetta2
# Check for the presence of the Rosetta 2 installation receipt
if command -v lsbom >/dev/null && lsbom -f /Library/Apple/System/Library/Receipts/com.apple.pkg.RosettaUpdateAuto.bom >/dev/null 2>&1; then
    info_printf "Rosetta2: Installed"
else
    error_printf "Rosetta2: NOT installed"
fi

# Uv Python Manager and Tools
printf "\n"
get_version "uv" "" "uv Python Package Installer"

# Shells
printf "\n"
info_printf "Shells:"
get_version "bash" "version" "Bash"
get_version "zsh" "" "Zsh"
printf "Current Shell: %s\n" "$SHELL"

# XCode Command Line Tools
printf "\n"
info_printf "Xcode Command Line Tools:"
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep -e 'package-id:' -e 'version: '

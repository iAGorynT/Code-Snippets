#!/bin/zsh

# Update BrewitLaunchd.sh with changes when necessary.

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2; exit 1; }
source "$FORMAT_LIBRARY"

clear
format_printf "Brew Update, Upgrade, and Cleanup..." "yellow" "bold"
printf "\n"

# HomeBrew Update
format_printf "HomeBrew Update..." "none" "brew"
printf "\n"
brew update
brew upgrade

# Cask Upgrade
format_printf "Cask Upgrade..." "none" "brew"
printf "\n"
brew upgrade --cask --greedy

# Create temporary Brewfile
format_printf "Creating temporary Brewfile..." "none" "brew"
printf "\n"
cd
brew bundle dump --file=Brewfile.new

# Check if previous Brewfile exists
if [[ -f Brewfile ]]; then
    format_printf "Comparing with existing Brewfile..." "none" "brew"
    
    # Compare files, ignoring whitespace
    if diff -w Brewfile Brewfile.new > /dev/null; then
        format_printf "No changes detected. Keeping existing Brewfile." "none" "brew"
        rm Brewfile.new
    else
        format_printf "Changes detected. Updating Brewfile..." "none" "brew"
        mv Brewfile Brewfile.backup
        mv Brewfile.new Brewfile
        chmod 644 Brewfile
        printf "Backup of previous Brewfile created as: Brewfile.backup\n"
    fi
else
    format_printf "No existing Brewfile found. Creating new one..." "none" "brew"
    mv Brewfile.new Brewfile
    chmod 644 Brewfile
fi

printf "Current Brewfile location: %s\n" "$(pwd)"
ls -al Brewfile
printf "\n"

# HomeBrew Cleanup
format_printf "HomeBrew Cleanup..." "none" "brew"
printf "\n"
brew autoremove
brew cleanup
brew list

printf "\n"
success_printf "Brew Update, Upgrade, and Cleanup Completed!"
printf "\n"

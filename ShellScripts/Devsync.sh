#!/bin/zsh

# Activate Function Library
source $HOME/ShellScripts/FLibFormatEcho.sh

clear
format_echo "Dev to GitHUB Sync Starting..." "yellow" "bold"
echo

# ShellScript Sync
format_echo "Syncing ShellScripts..." "green"
rsync -avhl "$HOME/ShellScripts/" "$HOME/Documents/GitHub/Code-Snippets/ShellScripts" --delete
echo


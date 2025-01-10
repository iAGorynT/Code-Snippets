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

# DotFiles Sync
format_echo "Syncing DotFiles..." "green"
rsync -avhl "$HOME/.gvimrc" "$HOME/Documents/GitHub/Code-Snippets/DotFiles" --delete
rsync -avhl "$HOME/.vimrc" "$HOME/Documents/GitHub/Code-Snippets/DotFiles" --delete
rsync -avhl "$HOME/.zshrc" "$HOME/Documents/GitHub/Code-Snippets/DotFiles" --delete
echo

format_echo "Sync Completed!" "green" "bold"

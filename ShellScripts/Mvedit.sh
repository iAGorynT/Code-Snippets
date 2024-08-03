#!/bin/zsh

# MacVim Launcher

# Open Existing File / Create New File If One Doesn't Exist
mvim () {
    local f
    for f; do
        test -e "$f" || touch "$f"
    done
    open -a macvim "$@"
}

# Perform MacVim Launcher Function
mvim $1


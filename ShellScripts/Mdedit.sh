#!/bin/zsh

# MacDown Launcher

# Open Existing File / Create New File If One Doesn't Exist
mdwn () {
    local f
    for f; do
        test -e "$f" || touch "$f"
    done
    open -a macdown "$@"
}

# Perform MacVim Launcher Function
mdwn $1


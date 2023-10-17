#!/bin/zsh

# THIS IS A DIALOG BOX TEST SHOWING AN "OK" AND "Quit" SCRIPT OPTION
clear

# Prompt for OK to continue or Quit to stop

# Make sure to use a word other than "Cancel" to stop.  Cancel will throw an error and cause 
# the script to abort.
ans="$(osascript -e 'display dialog "OK to Continue or Quit to Stop Script?" buttons {"OK", "Quit"} default button "OK"')"

if [ "$ans" = "button returned:OK" ]; then
    echo "Yes, continue script..."
    echo
    exit 0
else
    echo "No, cancel script..."
    echo
    exit 1
fi

# Use "echo $?" from command line after this script completes to view exit status

#!/bin/zsh

# Unload/Remove Homebrew Autoupdate using Launchd

clear
echo "Unloading/Removing Homebrew Autoupdate..."
echo

# Define variables for file paths
template_file="$HOME/Launchd/Launchd.plist"
userplistname="com.bin.${USERNAME}.brewit.plist"
grepname="com.bin.${USERNAME}.brewit"
userplist="$HOME/Launchd/${userplistname}"
launchagentfolder="$HOME/Library/LaunchAgents"
launchagentplist="${launchagentfolder}/${userplistname}"
launchagentlogfolder="$HOME/Library/Logs/${grepname}"

# Function to print error message and exit
function exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Unload the user-specific plist file using launchctl
if launchctl unload "$launchagentplist"; then
    echo "Launchd Agent ${launchagentplist} unloaded successfully."
    echo
    # Verify if the agent was unloaded
    if launchctl list | grep -q "$grepname"; then
        exit_with_error "Launchd Agent is still active."
    else
        # Remove user-specific plist file
        echo "Removing Launchd Agent..."
        rm $launchagentplist
        # Remove user-specific log file
        echo "Removing Launchd Agent log file..."
        rm -R $launchagentlogfolder
    fi
else
    exit_with_error "Failed to unload Launchd Agent."
fi

#!/bin/zsh

# Set up Homebrew Autoupdate using Launchd

clear
echo "Loading Homebrew Autoupdate..."
echo

# Define variables for file paths
template_file="$HOME/Launchd/Launchd.plist"
userplistname="com.bin.${USERNAME}.brewit.plist"
grepname="com.bin.${USERNAME}.brewit"
userplist="$HOME/Launchd/${userplistname}"
launchagentfolder="$HOME/Library/LaunchAgents"
launchagentplist="${launchagentfolder}/${userplistname}"

# Function to print error message and exit
function exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Check if the template file exists
if [[ ! -f $template_file ]]; then
    exit_with_error "Launchd.plist file not found!"
fi

# Create LaunchAgents directory if it does not exist
mkdir -p "$launchagentfolder"

# Replace $UNAME placeholder with the $USERNAME value and create the user-specific plist
if sed "s|\$UNAME|$USERNAME|g" "$template_file" > "$userplist"; then
    echo "User-specific Launchd.plist file created: $userplist"
else
    exit_with_error "Failed to create the user-specific plist file!"
fi
echo

# Copy the user-specific plist file to LaunchAgents folder
if cp "$userplist" "$launchagentplist"; then
    echo "User plist copied to Library LaunchAgents folder..."
else
    exit_with_error "Failed to copy ${userplist} to ${launchagentfolder}!"
fi
echo

# Load the user-specific plist file using launchctl
if launchctl load "$launchagentplist"; then
    echo "Launchd Agent ${launchagentplist} loaded successfully."
    # Verify if the agent was loaded
    if launchctl list | grep -q "$grepname"; then
        echo "Launchd Agent is active."
    else
        echo "Warning: Launchd Agent may not be active."
    fi
else
    exit_with_error "Failed to load Launchd Agent."
fi

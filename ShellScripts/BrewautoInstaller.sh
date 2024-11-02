#!/bin/zsh

# Install Brew Autoupdate System from GitHub Repository
clear
echo "Installing Brew Autoupdate System..."
echo

# Define variables using readonly to prevent accidental modification
readonly BIN_FOLDER="$HOME/bin"
readonly LAUNCHD_FOLDER="$HOME/Launchd"

# Function to display error messages based on the return code
display_message() {
    local ret_code=$1
    case $ret_code in
        0)
            echo "Download completed successfully."
            ;;
        1)
            echo "Usage error or download canceled by user."
            ;;
        2)
            echo "Download failed. This could be due to a network issue or the file not existing on GitHub."
            ;;
        3)
            echo "Error: curl is not installed. Please install curl to run this script."
            ;;
        *)
            echo "An unknown error occurred with exit code $ret_code."
            ;;
    esac
}

# Make User Bin Direcory and Download Shell Scripts
mkdir -p "$BIN_FOLDER"
cd "$BIN_FOLDER"

# Run the GitHub download script
GithubDownloader.sh iAGorynT Brew-Autoupdate main bin/Brewautom2.sh
ret_code=$?

# Call the display_message function with the return code
display_message $ret_code
echo

# Run the GitHub download script
GithubDownloader.sh iAGorynT Brew-Autoupdate main bin/BrewitLaunchd.sh
ret_code=$?

# Call the display_message function with the return code
display_message $ret_code
echo

# Make User Launchd Direcory and Download Plist Files
mkdir -p "$LAUNCHD_FOLDER"
cd "$LAUNCHD_FOLDER"

# Run the GitHub download script
$HOME/bin/GithubDownloader.sh iAGorynT Brew-Autoupdate main Launchd/Launchd.plist
ret_code=$?

# Call the display_message function with the return code
display_message $ret_code
echo

# Completed Message
echo "Installation Completed..."
echo

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

# Function to download a file from GitHub
download_github_file() {
    # Check if curl is installed
    if ! command -v curl &>/dev/null; then
        echo "Error: curl is not installed. Please install curl to use this script."
        return 3
    fi

    # Check if all required arguments are provided
    if [ "$#" -ne 4 ]; then
        echo "Usage: $0 owner repo branch filepath"
        echo "Example: $0 microsoft vscode main README.md"
        return 1
    fi

    local owner=$1
    local repo=$2
    local branch=$3
    local filepath=$4
    local github_raw_url="https://raw.githubusercontent.com/${owner}/${repo}/${branch}/${filepath}"
    local filename=$(basename "$filepath")
    
    # Check if the file already exists and prompt for overwrite
    if [ -f "$filename" ]; then
        read "overwrite?File $filename already exists. Overwrite? (y/N): "
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            echo "Download canceled."
            return 1
        fi
    fi

    # Attempt to download the file
    echo "Downloading ${filename} from ${github_raw_url}..."
    
    if curl -L -o "$filename" "$github_raw_url"; then
        echo "Successfully downloaded ${filename}"
        echo "File saved as: $(pwd)/${filename}"
        return 0
    else
        echo "Error: Failed to download the file from ${github_raw_url}"
        return 2
    fi
}

# Make User Bin Directory and Download Shell Scripts
mkdir -p "$BIN_FOLDER"
cd "$BIN_FOLDER"

# Download files using the download_github_file function
download_github_file iAGorynT Brew-Autoupdate main bin/Brewautom2.sh
ret_code=$?
display_message $ret_code
echo

download_github_file iAGorynT Brew-Autoupdate main bin/BrewitLaunchd.sh
ret_code=$?
display_message $ret_code
echo

# Make User Launchd Directory and Download Plist Files
mkdir -p "$LAUNCHD_FOLDER"
cd "$LAUNCHD_FOLDER"

download_github_file iAGorynT Brew-Autoupdate main Launchd/Launchd.plist
ret_code=$?
display_message $ret_code
echo

# Completed Message
echo "Installation Completed..."
echo

#!/bin/zsh

# Install Brew Autoupdate System from GitHub Repository
clear
printf "Installing Brew Autoupdate System...\n\n"

# Define variables using readonly to prevent accidental modification
readonly BIN_FOLDER="$HOME/bin"
readonly LAUNCHD_FOLDER="$HOME/Launchd"
readonly GITHUB_BASE_URL="https://raw.githubusercontent.com/iAGorynT/Brew-Autoupdate/main"

# Function to display error messages based on the return code
display_message() {
    case $1 in
        0) printf "Download completed successfully.\n" ;;
        1) printf "Usage error or download canceled by user.\n" ;;
        2) printf "Download failed. This could be due to a network issue or the file not existing on GitHub.\n" ;;
        3) printf "Error: curl is not installed. Please install curl to run this script.\n" ;;
        *) printf "An unknown error occurred with exit code %d.\n" "$1" ;;
    esac
}

# Function to download a file from GitHub
download_github_file() {
    # Check if curl is installed
    command -v curl &>/dev/null || { printf "Error: curl is not installed. Please install curl to use this script.\n"; return 3; }

    # Check if all required arguments are provided
    if [ "$#" -ne 2 ]; then
        printf "Usage: %s filepath destination_dir\n" "$0"
        return 1
    fi

    local filepath=$1
    local dest_dir=$2
    local filename=${filepath##*/}
    local full_url="$GITHUB_BASE_URL/$filepath"
    local dest_path="$dest_dir/$filename"

    # Check if the file already exists and prompt for overwrite
    if [ -f "$dest_path" ]; then
        read -q "?File $filename already exists. Overwrite? (y/N): " || { printf "\nDownload canceled.\n"; return 1; }
        printf "\n"
    fi

    printf "Downloading %s...\n" "$filename"
    if curl -sL -o "$dest_path" "$full_url"; then
        printf "Successfully downloaded %s to %s\n" "$filename" "$dest_path"
        return 0
    else
        printf "Error: Failed to download %s\n" "$filename"
        return 2
    fi
}

# Create directories if they don't exist
if [ ! -d "$BIN_FOLDER" ]; then
    printf "Creating directory: %s\n" "$BIN_FOLDER"
    mkdir -p "$BIN_FOLDER"
fi

if [ ! -d "$LAUNCHD_FOLDER" ]; then
    printf "Creating directory: %s\n" "$LAUNCHD_FOLDER"
    mkdir -p "$LAUNCHD_FOLDER"
fi

# Create symbolic link if it doesn't exist or points to wrong location
if [ ! -L "$HOME/ShellScripts" ] || [ "$(readlink "$HOME/ShellScripts")" != "$BIN_FOLDER" ]; then
    printf "Creating symbolic link: ShellScripts -> %s\n" "$BIN_FOLDER"
    ln -sf "$BIN_FOLDER" "$HOME/ShellScripts"
fi

# Download bin files
cd "$BIN_FOLDER" || exit 1
for file in Brewautom2.sh BrewitLaunchd.sh FLibFormatEcho.sh; do
    download_github_file "bin/$file" "$BIN_FOLDER"
    display_message $?
    printf "\n"
done

# Download Launchd file
cd "$LAUNCHD_FOLDER" || exit 1
download_github_file "Launchd/Launchd.plist" "$LAUNCHD_FOLDER"
display_message $?

printf "\nInstallation Completed...\n\n"

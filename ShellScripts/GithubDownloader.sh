#!/bin/zsh

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

download_github_file "$@"
# Pass the function's return status to the shell
exit $?

#!/bin/zsh
download_github_file() {
    # Early exit if curl is not installed
    command -v curl &>/dev/null || { printf >&2 "Error: curl is not installed. Please install curl to use this script.\n"; return 3; }

    # Validate argument count
    [[ "$#" -eq 4 ]] || { 
        printf >&2 "Usage: %s owner repo branch filepath\n" "$0"
        printf >&2 "Example: %s microsoft vscode main README.md\n" "$0"
        return 1 
    }

    local owner=$1 repo=$2 branch=$3 filepath=$4
    local github_raw_url="https://raw.githubusercontent.com/${owner}/${repo}/${branch}/${filepath}"
    local filename=$(basename "$filepath")
    
    # Prompt for overwrite with printf
    [[ -f "$filename" ]] && {
        printf "File %s exists. Overwrite? (y/N) " "$filename"
        read -q || { printf "\nDownload canceled.\n"; return 1; }
        printf "\n"
    }

    # Streamlined download with error handling
    if curl -L -f -s -o "$filename" "$github_raw_url"; then
        printf "Downloaded %s to %s\n" "$filename" "$(pwd)/${filename}"
        return 0
    else
        printf >&2 "Error: Failed to download file from %s\n" "$github_raw_url"
        return 2
    fi
}
download_github_file "$@"
exit $?

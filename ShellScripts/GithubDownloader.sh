#!/bin/zsh
parse_github_url() {
    local url="$1"
    local github_regex='^https?://github.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)$'

    if [[ "$url" =~ $github_regex ]]; then
        printf "%s\n%s\n%s\n%s" "$match[1]" "$match[2]" "$match[3]" "$match[4]"
    else
        printf >&2 "Error: Invalid GitHub URL format\n"
        printf >&2 "Usage: https://github.com/iAGorynT/Code-Snippets/blob/main/README.md\n"
        return 1
    fi
}

download_github_file() {
    # Early exit if curl is not installed
    command -v curl &>/dev/null || { printf >&2 "Error: curl is not installed. Please install curl to use this script.\n"; return 3; }

    local github_url="$1"
    local parsed_details
    parsed_details=($(parse_github_url "$github_url"))
    local ret=$?

    [[ $ret -ne 0 ]] && return $ret

    local owner="${parsed_details[1]}"
    local repo="${parsed_details[2]}"
    local branch="${parsed_details[3]}"
    local filepath="${parsed_details[4]}"

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

# Main
[[ $# -eq 0 ]] && { printf >&2 "Error: Missing GitHub URL argument\n"; exit 1; }	# Exit if no URL provided
printf "Downloading file from GitHub...\n\n"

# Usage: ./script.zsh https://github.com/owner/repo/blob/branch/filepath
download_github_file "$@"
exit $?


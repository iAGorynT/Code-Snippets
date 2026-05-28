#!/bin/zsh

# Delete a GitHub fork and its local clone
# Usage: ./delete-fork.sh (prompts for repository name to delete)

# Source function library with error handling

SCRIPT_DIR="${0:a:h}"
FORMAT_LIBRARY="$SCRIPT_DIR/FLibFormatPrintf.sh"

if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    printf "Error: Required library not found: %s\n" "$FORMAT_LIBRARY" >&2
    printf "Searched in script directory: %s\n" "$SCRIPT_DIR" >&2
    exit 1
fi

source "$FORMAT_LIBRARY"

# Heading
clear
format_printf "Delete Fork..." "yellow" "bold"
printf "\n"

# Prompt for repository name
info_printf "Please enter the name of the GitHub fork to delete."
read "REPO_NAME?Repo name: "
if [ -z "$REPO_NAME" ]; then
  error_printf "Repository name cannot be empty."
  exit 1
fi

LOCAL_DIR="$HOME/Documents/GitHub/$REPO_NAME"

# Get the current GitHub username (requires gh CLI)
GITHUB_USER=$(gh api user --jq .login)

# Confirm deletion
warning_printf "This will delete:"
format_printf "  - Remote repo: https://github.com/$GITHUB_USER/$REPO_NAME" none
format_printf "  - Local folder: $LOCAL_DIR" none
read -q "REPLY?Proceed? (y/n) "
echo
[[ $REPLY != [yY] ]] && { error_printf "Cancelled."; exit 0 }

# Delete remote repo
clean_printf "Deleting remote fork from GitHub..."
if gh repo delete "$GITHUB_USER/$REPO_NAME" --yes; then
  # Delete local directory only if remote deletion succeeded
  if [ -d "$LOCAL_DIR" ]; then
    clean_printf "Removing local clone..."
    rm -rf "$LOCAL_DIR"
  else
    warning_printf "Local directory not found: $LOCAL_DIR"
  fi
  success_printf "Done! The fork '$REPO_NAME' has been removed."
else
  error_printf "Failed to delete remote repository. Local directory was not removed."
  exit 1
fi

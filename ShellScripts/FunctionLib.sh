#!/bin/zsh

# Global Function Libraries

# Function: brew_echo
# Description: Format Text using the echo command and it's formatting options
# Arguments: <TEXTSTRING> <MULTIPLE FORMAT OPTIONS>
# Usage: brew_echo "Hello, World!" 1 4 7

function brew_echo() {
  local text="$1"
  shift
  local formats=("$@")

  # Array mapping numbers to formatting options
  local -A format_map=(
    [0]="\e[0m"  # Reset all attributes
    [1]="\e[1m"  # Bold
    [2]="\e[2m"  # Dim
    [3]="\e[3m"  # Italic
    [4]="\e[4m"  # Underline
    [5]="\e[5m"  # Blink
    [6]="\e[7m"  # Reverse
    [7]="\e[8m"  # Hidden
    [8]="\e[9m"  # Strikethrough
  )

  # Initialize an empty string for the format sequence
  local format_sequence=""

  # Build the format sequence from the provided format numbers
  for format in "${formats[@]}"; do
    if [[ -n "${format_map[$format]}" ]]; then
      format_sequence+="${format_map[$format]}"
    fi
  done

  # Print the formatted text with a reset at the end
  # NOTE: ==> will be printed in BLUE
  echo -e "\e[0;34m==>\e[0m ${format_sequence}${text}\e[0m"
}


#!/bin/zsh

# Global Function Libraries

# Function: format_echo
# Description: Format Text using the echo command and it's formatting options
# Arguments: <TEXTSTRING> <ECHO MESSAGE TYPE-brew/std> <MULTIPLE FORMAT OPTIONS>
# Usage: format_echo "Hello, World!" "brew" 1 4 7

function format_echo() {
  local text="$1"
  local echotype="$2"
  shift
  shift
  local formats=("$@")

  # Define color variables
  BLACK='\e[0;30m'
  RED='\e[0;31m'
  GREEN='\e[0;32m'
  YELLOW='\e[0;33m'
  BLUE='\e[0;34m'
  MAGENTA='\e[0;35m'
  CYAN='\e[0;36m'
  WHITE='\e[0;37m'
  RESET='\e[0m'

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

  if [ $echotype = 'brew' ]; then
  # Print the formatted text as a HomeBrew Message with a reset at the end
    echo -e "${BLUE}==>${RESET} ${format_sequence}${text}${RESET}"
  else
  # Print the formatted text as a Standard Message with a reset at the end
    echo -e "${format_sequence}${text}${RESET}"
  fi
}


#!/bin/zsh

# Function: FLibFormatEcho.sh 
# Desc: Text formatting library for ZSH scripts
# Usage: format_echo [text] [color] [format options...] [echotype]
# Colors: black, red, green, yellow, blue, magenta, cyan, white
# Format options: bold, dim, italic, underline, blink, reverse, hidden
# Echotype: brew/brewl (optional, for HomeBrew-style messages)

# ANSI escape code components
declare -A colors=(
    [black]="30"
    [red]="31"
    [green]="32"
    [yellow]="33"
    [blue]="34"
    [magenta]="35"
    [cyan]="36"
    [white]="37"
    [none]=""  # Added 'none' as a valid color option
)

declare -A formats=(
    [bold]="1"
    [dim]="2"
    [italic]="3"
    [underline]="4"
    [blink]="5"
    [reverse]="7"
    [hidden]="8"
)

# Reset all formatting
reset="\033[0m"
# Define blue color with bold for brew style
brewblue="\033[1;34m"
# Define Brown color with bold for brew style
brewbrown="\033[1;38;5;136m"
# Define bold format for brew style text
brewbold="\033[1m"

# Function to validate color input
validate_color() {
    local color=$1
    if [[ -z ${colors[$color]} && $color != "none" ]]; then
        echo "Invalid color: $color" >&2
        echo "Available colors: ${(k)colors}" >&2
        return 1
    fi
    return 0
}

# Function to validate format options
validate_format() {
    local format=$1
    if [[ -z ${formats[$format]} ]]; then
        echo "Invalid format: $format" >&2
        echo "Available formats: ${(k)formats}" >&2
        return 1
    fi
    return 0
}

# Main formatting function
format_echo() {
    local text=$1
    local color=${2:-none}  # Default color is 'none' if not specified
    local echotype=""       # Initialize echotype as empty
    shift 1  # Remove first argument (text)
    [[ $# -gt 0 ]] && shift 1  # Remove second argument (color) only if it exists

    # Process remaining arguments
    local format_args=()
    while [[ $# -gt 0 ]]; do
        if [[ $1 == "brew" ]]; then
            # Brew style
            echotype="brew"
        elif [[ $1 == "brewl" ]]; then
            # Brew Launchd style
            echotype="brewl"
        else
            format_args+=($1)
        fi
        shift
    done

    # Validate color if it's not 'none'
    if [[ $color != "none" ]]; then
        if ! validate_color $color; then
            return 1
        fi
    fi

    # Build format string
    local format_codes=()
    if [[ $color != "none" ]]; then
        local color_code=${colors[$color]}
        format_codes+=($color_code)
    fi

    # Process format options
    for opt in $format_args; do
        if validate_format $opt; then
            format_codes+=(${formats[$opt]})
        fi
    done

    # Print formatted text
    if [[ ${#format_codes} -eq 0 ]]; then
        if [[ $echotype == "brew" ]]; then
            # Print the formatted text as a HomeBrew Message with a reset at the end
            echo -e "${brewbrown}==>${reset} ${brewbold}${text}${reset}"
        elif [[ $echotype == "brewl" ]]; then
            # Print the formatted text as a HomeBrew Launchd Message
            echo -e "==> ${text}"
        else
            # No formatting needed
            echo -e "${text}"
        fi
    else
        # Join format codes with semicolons and apply formatting
        local format_string=$(IFS=\;; echo "${format_codes[*]}")
        echo -e "\033[${format_string}m${text}${reset}"
    fi
}

# Helper functions for common use cases
error_echo() {
    local message=$1
    local stop_execution=${2:-false}  # Optional parameter with default value of false
    
    format_echo "$message" "red" "bold"
    
    if [[ $stop_execution == true ]]; then
        format_echo "Stopping script execution." "red" "bold"
        exit 1
    fi
}

success_echo() {
    local message=$1
    format_echo "$message" "green" "bold"
}

warning_echo() {
    local message=$1
    format_echo "$message" "yellow" "bold"
}

info_echo() {
    local message=$1
    format_echo "$message" "blue" "bold"
}

# Example usage function
show_examples() {
    echo "Format Library Examples:"
    format_echo "Text without color or formatting"
    format_echo "Text with brew style" none brew
    format_echo "Text with brewl style" none brewl
    format_echo "Regular colored text" "blue"
    format_echo "Bold text without color" none "bold"
    format_echo "Bold colored text" "green" "bold"
    format_echo "Underlined text" "cyan" "underline"
    format_echo "Bold and underlined" "magenta" "bold" "underline"
    format_echo "Italic text without color" none "italic"
    format_echo "Error message" "red" "bold" "reverse"
    echo "\nHelper Functions:"
    error_echo "This is an error message"
    success_echo "This is a success message"
    warning_echo "This is a warning message"
    info_echo "This is an info message"
}

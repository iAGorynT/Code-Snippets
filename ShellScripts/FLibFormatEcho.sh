#!/bin/zsh

# Text formatting library for ZSH scripts
# Usage: format_echo [text] [color] [format options...]
# Colors: black, red, green, yellow, blue, magenta, cyan, white
# Format options: bold, dim, italic, underline, blink, reverse, hidden

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
    shift 1  # Remove first argument (text)
    [[ $# -gt 0 ]] && shift 1  # Remove second argument (color) only if it exists

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

    # Process additional format options
    for opt in $@; do
        if validate_format $opt; then
            format_codes+=(${formats[$opt]})
        fi
    done

    # Print formatted text
    if [[ ${#format_codes} -eq 0 ]]; then
        # No formatting needed
        echo -e "${text}"
    else
        # Join format codes with semicolons and apply formatting
        local format_string=$(IFS=\;; echo "${format_codes[*]}")
        echo -e "\033[${format_string}m${text}${reset}"
    fi
}

# Helper functions for common use cases
error_echo() {
    format_echo "$1" "red" "bold"
}

success_echo() {
    format_echo "$1" "green" "bold"
}

warning_echo() {
    format_echo "$1" "yellow" "bold"
}

info_echo() {
    format_echo "$1" "blue" "bold"
}

# Example usage function
show_examples() {
    echo "Format Library Examples:"
    format_echo "Text without color or formatting"
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

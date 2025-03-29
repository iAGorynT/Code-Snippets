#!/bin/zsh

# Function: FLibFormatPrintf.sh 
# Desc: Text formatting library for ZSH scripts using printf
# Usage: format_printf [text] [color] [format options...] [echotype]
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
        printf "Invalid color: %s\n" "$color" >&2
        printf "Available colors: %s\n" "${(k)colors}" >&2
        return 1
    fi
    return 0
}

# Function to validate format options
validate_format() {
    local format=$1
    if [[ -z ${formats[$format]} ]]; then
        printf "Invalid format: %s\n" "$format" >&2
        printf "Available formats: %s\n" "${(k)formats}" >&2
        return 1
    fi
    return 0
}

# Main formatting function
format_printf() {
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
            printf '%b==>%b %b%s%b\n' "${brewbrown}" "${reset}" "${brewbold}" "${text}" "${reset}"
        elif [[ $echotype == "brewl" ]]; then
            # Print the formatted text as a HomeBrew Launchd Message
            printf '==> %s\n' "${text}"
        else
            # No formatting needed
            printf '%s\n' "${text}"
        fi
    else
        # Join format codes with semicolons and apply formatting
        local format_string=$(IFS=\;; echo "${format_codes[*]}")
        printf '\033[%sm%s%b\n' "${format_string}" "${text}" "${reset}"
    fi
}

# Helper functions for common use cases
error_printf() {
    local message=$1
    local stop_execution=${2:-false}  # Optional parameter with default value of false
    
    format_printf "$message" "red" "bold"
    
    if [[ $stop_execution == true ]]; then
        format_printf "Stopping script execution." "red" "bold"
        exit 1
    fi
}

success_printf() {
    local message=$1
    format_printf "$message" "green" "bold"
}

warning_printf() {
    local message=$1
    format_printf "$message" "yellow" "bold"
}

info_printf() {
    local message=$1
    format_printf "$message" "blue" "bold"
}

# Check if the script is being sourced or run directly
# This is the proper zsh way to check if a script is being sourced
if [[ "${ZSH_EVAL_CONTEXT:-}" = "toplevel" || "${ZSH_EVAL_CONTEXT:-}" = "" ]]; then
    show_examples() {
        printf "Format Library Examples:\n"
        format_printf "Text without color or formatting"
        format_printf "Text with brew style" none brew
        format_printf "Text with brewl style" none brewl
        format_printf "Regular colored text" "blue"
        format_printf "Bold text without color" none "bold"
        format_printf "Bold colored text" "green" "bold"
        format_printf "Underlined text" "cyan" "underline"
        format_printf "Bold and underlined" "magenta" "bold" "underline"
        format_printf "Italic text without color" none "italic"
        format_printf "Error message" "red" "bold" "reverse"
        printf "\nHelper Functions:\n"
        error_printf "This is an error message"
        success_printf "This is a success message"
        warning_printf "This is a warning message"
        info_printf "This is an info message"
    }
    
    show_examples
fi

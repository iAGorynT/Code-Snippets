#!/bin/zsh

# Function: FLibFormatPrintf.sh 
# Desc: Text formatting library for ZSH scripts using printf with icon support
# Usage: format_printf [text] [color] [format options...] [echotype] [icon]
# Colors: black, red, green, yellow, blue, magenta, cyan, white
# Format options: bold, dim, italic, underline, blink, reverse, hidden
# Echotype: brew/brewl (optional, for HomeBrew-style messages)
# Icon: emoji or icon character to prepend to the message (optional)

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

# Common icons for messaging
declare -A icons=(
    [info]="ℹ️ "
    [success]="✅"
    [warning]="⚠️"
    [error]="❌"
    [update]="🔄"
    [package]="📦"
    [time]="🕒"
    [upgrade]="⬆️ "
    [rocket]="🚀"
    [log]="📄"
    [clean]="🧹"
    [stats]="📊"
    [none]=""  # No icon
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

# Function to validate icon
validate_icon() {
    local icon=$1
    # If the icon is not in our predefined icons but is a direct emoji or character, it's still valid
    if [[ -z ${icons[$icon]} && $icon != "none" && ${#icon} -gt 2 ]]; then
        printf "Warning: Using custom icon: %s\n" "$icon" >&2
        printf "Available predefined icons: %s\n" "${(k)icons}" >&2
    fi
    return 0
}

# Main formatting function
format_printf() {
    local text=$1
    local color=${2:-none}  # Default color is 'none' if not specified
    local echotype=""       # Initialize echotype as empty
    local icon=""           # Initialize icon as empty
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
        elif [[ -n ${icons[$1]} || ${#1} -le 2 ]]; then
            # It's an icon name from our predefined list or a direct emoji/character
            if [[ -n ${icons[$1]} ]]; then
                icon="${icons[$1]} "  # Use predefined icon with space
            elif [[ $1 != "none" ]]; then
                icon="$1 "  # Use custom icon with space
            fi
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
            printf '%b==>%b %b%s%s%b\n' "${brewbrown}" "${reset}" "${brewbold}" "${icon}" "${text}" "${reset}"
        elif [[ $echotype == "brewl" ]]; then
            # Print the formatted text as a HomeBrew Launchd Message
            printf '==> %s%s\n' "${icon}" "${text}"
        else
            # No formatting needed
            printf '%s%s\n' "${icon}" "${text}"
        fi
    else
        # Join format codes with semicolons and apply formatting
        local format_string=$(IFS=\;; echo "${format_codes[*]}")
        printf '\033[%sm%s%s%b\n' "${format_string}" "${icon}" "${text}" "${reset}"
    fi
}

# Helper functions for common use cases
error_printf() {
    local message=$1
    local stop_execution=${2:-false}  # Optional parameter with default value of false
    
    format_printf "$message" "red" "bold" "error"
    
    if [[ $stop_execution == true ]]; then
        format_printf "Stopping script execution." "red" "bold" "error"
        exit 1
    fi
}

success_printf() {
    local message=$1
    format_printf "$message" "green" "bold" "success"
}

warning_printf() {
    local message=$1
    format_printf "$message" "yellow" "bold" "warning"
}

info_printf() {
    local message=$1
    format_printf "$message" "blue" "bold" "info"
}

# Additional helpers with icons
update_printf() {
    local message=$1
    format_printf "$message" "blue" "bold" "update"
}

package_printf() {
    local message=$1
    format_printf "$message" "cyan" "bold" "package"
}

time_printf() {
    local message=$1
    format_printf "$message" "cyan" "italic" "time"
}

upgrade_printf() {
    local message=$1
    format_printf "$message" "magenta" "bold" "upgrade"
}

rocket_printf() {
    local message=$1
    format_printf "$message" "cyan" "bold" "rocket"
}

log_printf() {
    local message=$1
    format_printf "$message" "blue" "italic" "log"
}

clean_printf() {
    local message=$1
    format_printf "$message" "green" "italic" "clean"
}

stats_printf() {
    local message=$1
    format_printf "$message" "magenta" "bold" "stats"
}

# Function to print to both console and log file
tee_printf() {
    local message=$1
    local color=${2:-none}
    local log_file=${3:-""}
    local icon=${4:-"none"}
    
    # Print to console with formatting
    format_printf "$message" "$color" "$icon"
    
    # Print to log file without formatting if log file is specified
    if [[ -n "$log_file" ]]; then
        if [[ -n "${icons[$icon]}" ]]; then
            echo "${icons[$icon]} $message" >> "$log_file"
        else
            echo "$message" >> "$log_file"
        fi
    fi
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
        
        printf "\nHelper Functions with Icons:\n"
        error_printf "This is an error message"
        success_printf "This is a success message"
        warning_printf "This is a warning message"
        info_printf "This is an info message"
        
        printf "\nNew Icon Functions:\n"
        update_printf "This is an update message"
        package_printf "This is a package message"
        time_printf "This is a time message"
        upgrade_printf "This is an upgrade message"
        rocket_printf "This is a rocket message"
        log_printf "This is a log message"
        clean_printf "This is a clean message"
        stats_printf "This is a stats message"
        
        printf "\nCustom Icons:\n"
        format_printf "Message with custom emoji" "cyan" "bold" "🌟"
        format_printf "Another custom icon" "yellow" "italic" "💻"
        
        printf "\nIcon list:\n"
        for icon in "${(@k)icons}"; do
            [[ $icon == "none" ]] && continue
            printf "%-10s: %s\n" "$icon" "${icons[$icon]}"
        done
    }
    
    show_examples
fi

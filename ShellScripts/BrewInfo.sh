#!/bin/zsh

# Brew Info Viewer
# This script provides an interactive menu to view detailed information about Homebrew packages (formulae and casks).

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Initialize global variables
scroll_offset=0
MENU_LENGTH=10
formulae=()
casks=()
all_packages=()

# Function to display script header
display_header() {
    clear
    format_printf "Brew Info Viewer..." "yellow" "bold"
    printf "\n"
}

# Function to prompt for menu length
prompt_menu_length() {
    local -a options=("5" "10" "20")
    
    printf "Select menu length (items per page):\n"
    local i=1
    for opt in "${options[@]}"; do
        printf "%d) %s items\n" "$i" "$opt"
        ((i++))
    done
    printf "\n"
    
    local choice
    while true; do
        read "choice?Enter choice (default: 3): "
        if [[ -z "$choice" ]]; then
            choice=3
        fi
        if [[ "$choice" =~ ^[1-3]$ ]]; then
            MENU_LENGTH=${options[$((choice))]}
            info_printf "Menu length set to $MENU_LENGTH items per page."
            return 0
        else
            warning_printf "Invalid choice. Please enter a number between 1 and 3."
        fi
    done
}

# Function to get terminal size
function get_terminal_size() {
    local lines cols
    
    lines=$(tput lines 2>/dev/null)
    cols=$(tput cols 2>/dev/null)
    
    [[ -z "$lines" || "$lines" -lt 1 ]] && lines=30
    [[ -z "$cols" || "$cols" -lt 1 ]] && cols=80
    
    echo "$lines $cols"
}

# Function to display paged menu
function show_paged_menu() {
    local -a packages=("$@")
    local total=${#packages[@]}
    local page_size=$MENU_LENGTH

    [[ $scroll_offset -lt 0 ]] && scroll_offset=0
    local max_offset=$((total - page_size))
    [[ $max_offset -lt 0 ]] && max_offset=0
    [[ $scroll_offset -gt $max_offset ]] && scroll_offset=$max_offset

    local end=$((scroll_offset + page_size))
    [[ $end -gt $total ]] && end=$total

    printf "--- Showing %d-%d of %d ---\n" $((scroll_offset + 1)) "$end" "$total"

    local i=1
    for package in "${packages[@]}"; do
        if (( i > scroll_offset && i <= end )); then
            printf "%d) %s\n" "$i" "$package"
        fi
        ((i++))
    done

    printf "0) Exit\n"
    printf "\n"
    printf "Navigation: g=top, G=bottom, u=up, d=down, number=select package\n"
    printf "\n"
}

# Function to fetch installed packages
function fetch_packages() {
    info_printf "Fetching installed formulae..."
    formulae=($(brew list --formula))
    info_printf "Fetching installed casks..."
    casks=($(brew list --cask))
    all_packages=("${formulae[@]}" "${casks[@]}")
}

# Function to display package counts
function show_package_counts() {
    stats_printf "Number of formulae: ${#formulae[@]}"
    stats_printf "Number of casks: ${#casks[@]}"
    stats_printf "Total number of packages: ${#all_packages[@]}"
    printf "\n"
}

# Function to get package type (formulae or cask)
function get_package_type() {
    local package=$1
    if [[ " ${casks[@]} " =~ " ${package} " ]]; then
        echo "cask"
    else
        echo "formulae"
    fi
}

# Function to extract version from brew --prefix path
function extract_version() {
    local prefix_path=$1
    local version=""
    
    if [[ -n "$prefix_path" ]]; then
        version=$(basename "$prefix_path")
    fi
    
    echo "$version"
}

# Function to perform cleanup before exit
function perform_cleanup() {
    info_printf "Running brew cleanup..."
    brew cleanup --prune=7d 2>/dev/null
    success_printf "Cleanup complete."
}

# Function to display package information
function show_package_info() {
    local package=$1
    local type=$(get_package_type "$package")
    
    printf "\n"
    info_printf "=== ${package} Information ==="
    printf "\n"
    
    local type_display="formulae"
    [[ "$type" == "cask" ]] && type_display="cask"
    printf "Type: %s\n" "$type_display"
    
    local prefix_path
    if [[ "$type" == "cask" ]]; then
        prefix_path=$(brew --prefix "caskroom/$package" 2>/dev/null)
        if [[ -z "$prefix_path" ]]; then
            prefix_path=$(brew --prefix "$package" 2>/dev/null)
        fi
    else
        prefix_path=$(brew --prefix "$package" 2>/dev/null)
    fi
    
    if [[ -n "$prefix_path" ]]; then
        local resolved_path="$prefix_path"
        if [[ -L "$prefix_path" ]]; then
            resolved_path=$(readlink -f "$prefix_path")
        fi
        
        printf "Install Path: %s\n" "$resolved_path"
        
        if [[ "$resolved_path" =~ /Cellar/([^/]+)/([^/]+)$ ]]; then
            printf "Version: %s\n" "${match[2]}"
        elif [[ "$resolved_path" =~ /opt/homebrew/Cellar/([^/]+)/([^/]+)$ ]]; then
            printf "Version: %s\n" "${match[2]}"
        else
            printf "Version: Unknown\n"
        fi
    else
        printf "Install Path: Not found\n"
        printf "Version: Unknown\n"
    fi
    
    printf "\n"
    info_printf "--- brew info output ---"
    printf "\n"
    
    if [[ "$type" == "cask" ]]; then
        brew info --cask "$package"
    else
        brew info "$package"
    fi
    
    printf "\n"
}

# Main script
display_header
fetch_packages
scroll_offset=0

if [ ${#all_packages[@]} -eq 0 ]; then
    warning_printf "No Homebrew packages found. Exiting."
    perform_cleanup
    exit 0
fi

printf "\n"
prompt_menu_length

while true; do
    display_header
    show_package_counts

    if [ ${#all_packages[@]} -eq 0 ]; then
        warning_printf "No Homebrew packages found. Exiting."
        perform_cleanup
        exit 0
    fi

    info_printf "Installed Homebrew packages:"
    show_paged_menu "${all_packages[@]}"

    read "choice?Enter navigation key or package number (0 to exit): "
    choice=${choice:-0}

    if [[ "$choice" == "g" ]]; then
        scroll_offset=0
        continue
    elif [[ "$choice" == "G" ]]; then
        local max_offset=$((${#all_packages[@]} - MENU_LENGTH))
        ((max_offset < 0)) && max_offset=0
        scroll_offset=$max_offset
        continue
    elif [[ "$choice" == "u" ]]; then
        ((scroll_offset -= MENU_LENGTH / 2))
        ((scroll_offset < 0)) && scroll_offset=0
        continue
    elif [[ "$choice" == "d" ]]; then
        local max_offset=$((${#all_packages[@]} - MENU_LENGTH))
        ((max_offset < 0)) && max_offset=0
        ((scroll_offset += MENU_LENGTH / 2))
        [[ $scroll_offset -gt $max_offset ]] && scroll_offset=$max_offset
        continue
    fi

    if [[ $choice =~ ^[0-9]+$ ]]; then
        if (( choice == 0 )); then
            info_printf "Exiting. Brew Info Viewer completed."
            perform_cleanup
            exit 0
        elif (( choice <= ${#all_packages[@]} )); then
            selected_package=${all_packages[$choice]}
            
            display_header
            show_package_info "$selected_package"
            
            printf "\n"
            read "continue?Press any key to continue or type 'exit' to quit: "
            if [[ $continue == "exit" ]]; then
                info_printf "Exiting. Brew Info Viewer completed."
                perform_cleanup
                exit 0
            fi
        else
            warning_printf "Invalid selection. Please enter a number between 0 and ${#all_packages[@]}."
            sleep 1
        fi
    else
        warning_printf "Invalid input. Please enter a number."
        sleep 1
    fi

    printf "\n"
done

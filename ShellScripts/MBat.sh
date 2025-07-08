#!/bin/zsh

# Bat menu viewer
# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# This script collects all files in the bin directory that end with 'm.sh'
cd "$HOME/bin" || exit 1

# Function to display script header
display_header() {
    clear
    format_printf "Bat Menu Viewer..." "yellow" "bold"
    printf "\n"
}

# Function to display menu
function show_menu() {
    local i=1
    for menu_file in "$@"; do
        format_printf "$i) $menu_file"
        ((i++))
    done
    format_printf "0) Exit"
    printf "\n"
}

# Function to fetch installed menu_files
function fetch_menu_files() {
    all_menu_files=(*m.sh(N))
}

# Function to display menu_file counts
function show_menu_file_counts() {
    info_printf "Total number of menu_files: ${#all_menu_files[@]}"
    printf "\n"
}

# Function to uninstall a menu_file
function view_menu_file() {
    local menu_file=$1
    bat "$menu_file" || cat "$menu_file" || { error_printf "Unable to display $menu_file"; return 1; }
}

# Main script
# Initialize menu_file lists
fetch_menu_files

# Main loop
while true; do

    display_header
    show_menu_file_counts

    if [ ${#all_menu_files[@]} -eq 0 ]; then
        warning_printf "No menu files found. Exiting."
        exit 0
    fi

    info_printf "Installed Menu Files:"
    show_menu "${all_menu_files[@]}"

    read "choice?Enter the number of the menu file you want to view (0 to exit): "
    choice=${choice:-0}  # Set default value to 0 if input is empty

    if [[ $choice =~ ^[0-9]+$ ]]; then
        if (( choice == 0 )); then
            success_printf "Exiting... Bat Menu Viewer completed."
            exit 0
        elif (( choice <= ${#all_menu_files[@]} )); then
            selected_menu_file=${all_menu_files[$choice]}
            view_menu_file "$selected_menu_file"
        else
            error_printf "Invalid selection. Please enter a number between 0 and ${#all_menu_files[@]}."
        fi
    else
        error_printf "Invalid input. Please enter a number."
    fi

    printf "\n"
    read "continue?Press any key to continue or type 'exit' to quit: "
    if [[ $continue == "exit" ]]; then
        success_printf "Exiting... Bat Menu Viewer completed."
        exit 0
    else
        clear
        printf "\n"
    fi
done


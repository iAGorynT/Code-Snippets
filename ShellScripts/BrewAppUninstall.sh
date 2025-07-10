#!/bin/zsh

# Brew App Uninstaller
# This script provides an interactive menu to uninstall Homebrew packages (formulae and casks).

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Function to display script header
display_header() {
    clear
    format_printf "Brew App Uninstaller..." "yellow" "bold"
    printf "\n"
}

# Function to display menu
function show_menu() {
    local i=1
    for package in "$@"; do
        printf "%d) %s\n" "$i" "$package"
        ((i++))
    done
    printf "0) Exit\n"
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

# Function to uninstall a package
function uninstall_package() {
    local package=$1
    if [[ " ${casks[@]} " =~ " ${package} " ]]; then
        brew uninstall --cask "$package"
    else
        brew uninstall "$package"
    fi
    brew autoremove
    success_printf "$package has been uninstalled."
    all_packages=("${(@)all_packages:#$package}")
}

# Main script
# Initialize package lists
fetch_packages

# Main loop
while true; do

    display_header
    show_package_counts

    if [ ${#all_packages[@]} -eq 0 ]; then
        warning_printf "No Homebrew packages found. Exiting."
        exit 0
    fi

    info_printf "Installed Homebrew packages:"
    show_menu "${all_packages[@]}"

    read "choice?Enter the number of the package you want to uninstall (0 to exit): "
    choice=${choice:-0}  # Set default value to 0 if input is empty

    if [[ $choice =~ ^[0-9]+$ ]]; then
        if (( choice == 0 )); then
            info_printf "Exiting. No packages were uninstalled."
            exit 0
        elif (( choice <= ${#all_packages[@]} )); then
            selected_package=${all_packages[$choice]}
            
            read "confirm?Are you sure you want to uninstall $selected_package? (y/n): "
            if [[ $confirm =~ ^[Yy]$ ]]; then
                uninstall_package "$selected_package"
            else
                info_printf "Uninstallation cancelled."
            fi
        else
            warning_printf "Invalid selection. Please enter a number between 0 and ${#all_packages[@]}."
        fi
    else
        warning_printf "Invalid input. Please enter a number."
    fi

    printf "\n"
    read "continue?Press any key to continue or type 'exit' to quit: "
    if [[ $continue == "exit" ]]; then
        info_printf "Exiting. Brew App Uninstaller completed."
        exit 0
    else
        clear
        printf "\n"
    fi
done


#!/bin/zsh

# Brew App Uninstaller
# This script provides an interactive menu to uninstall Homebrew packages (formulae and casks).

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2; exit 1; }
source "$FORMAT_LIBRARY"

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
    printf "Number of formulae: %d\n" "${#formulae[@]}"
    printf "Number of casks: %d\n" "${#casks[@]}"
    printf "Total number of packages: %d\n" "${#all_packages[@]}"
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
    printf "%s has been uninstalled.\n" "$package"
    all_packages=("${(@)all_packages:#$package}")
}

# Main script
clear
format_printf "Brew App Uninstaller..." "yellow" "bold"
printf "\n"

# Initialize package lists
fetch_packages
show_package_counts

# Main loop
while true; do
    if [ ${#all_packages[@]} -eq 0 ]; then
        printf "No Homebrew packages found. Exiting.\n"
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
                printf "Uninstallation cancelled.\n"
            fi
        else
            printf "Invalid selection. Please enter a number between 0 and %d.\n" "${#all_packages[@]}"
        fi
    else
        printf "Invalid input. Please enter a number.\n"
    fi

    printf "\n"
    read "continue?Hit any key to continue or type 'exit' to quit: "
    if [[ $continue == "exit" ]]; then
        printf "Exiting. Brew App Uninstaller completed.\n"
        exit 0
    else
        clear
        printf "\n"
    fi
done


#!/bin/zsh

# Brew App Uninstaller
# This script provides an interactive menu to uninstall Homebrew packages (formulae and casks).

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatEcho.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    echo "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

# Function to display menu
function show_menu() {
    local i=1
    for package in "$@"; do
        echo "$i) $package"
        ((i++))
    done
    echo "0) Exit"
    echo
}

# Function to fetch installed packages
function fetch_packages() {
    info_echo "Fetching installed formulae..."
    formulae=($(brew list --formula))
    info_echo "Fetching installed casks..."
    casks=($(brew list --cask))
    all_packages=("${formulae[@]}" "${casks[@]}")
}

# Function to display package counts
function show_package_counts() {
    echo "Number of formulae: ${#formulae[@]}"
    echo "Number of casks: ${#casks[@]}"
    echo "Total number of packages: ${#all_packages[@]}"
    echo
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
    echo "$package has been uninstalled."
    all_packages=("${(@)all_packages:#$package}")
}

# Main script
clear
format_echo "Brew App Uninstaller..." "yellow" "bold"
echo

# Initialize package lists
fetch_packages
show_package_counts

# Main loop
while true; do
    if [ ${#all_packages[@]} -eq 0 ]; then
        echo "No Homebrew packages found. Exiting."
        exit 0
    fi

    info_echo "Installed Homebrew packages:"
    show_menu "${all_packages[@]}"

    read "choice?Enter the number of the package you want to uninstall (0 to exit): "
    choice=${choice:-0}  # Set default value to 0 if input is empty

    if [[ $choice =~ ^[0-9]+$ ]]; then
        if (( choice == 0 )); then
            info_echo "Exiting. No packages were uninstalled."
            exit 0
        elif (( choice <= ${#all_packages[@]} )); then
            selected_package=${all_packages[$choice]}
            
            read "confirm?Are you sure you want to uninstall $selected_package? (y/n): "
            if [[ $confirm =~ ^[Yy]$ ]]; then
                uninstall_package "$selected_package"
            else
                echo "Uninstallation cancelled."
            fi
        else
            echo "Invalid selection. Please enter a number between 0 and ${#all_packages[@]}."
        fi
    else
        echo "Invalid input. Please enter a number."
    fi

    echo
    read "continue?Press Enter to continue or type 'exit' to quit: "
    if [[ $continue == "exit" ]]; then
        echo "Exiting. Brew App Uninstaller completed."
        exit 0
    else
        clear
        echo
    fi
done


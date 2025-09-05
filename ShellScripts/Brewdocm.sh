#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

# Standard Message Formatting Library and Functions
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

function brewdocs1 {
	clear
	format_printf "HomeBrew Update 1/3..." "none" "brew"
	echo " "
	brew update
	echo " "
	info_printf "Fix any errors and continue with Step 2"
	info_printf "cmd-doubleclick for troubleshooting info: https://docs.brew.sh/Troubleshooting"
}

function brewdocs2 {
	clear
	format_printf "HomeBrew Update 2/3..." "none" "brew"
	echo " "
	brew update
	echo " "
	info_printf "Fix any errors and continue with Step 3"
	info_printf "cmd-doubleclick for troubleshooting info: https://docs.brew.sh/Troubleshooting"
}

function brewdocs3 {
	clear
	format_printf "Brew Doctor 3/3..." "none" "brew"
	echo " "
	brew doctor
	echo " "
	info_printf "Fix any errors to complete Brew Doctor Recovery"
	info_printf "cmd-doubleclick for troubleshooting info: https://docs.brew.sh/Troubleshooting"
}

function menu {
    clear
    printf "\n"
    printf "\t\t\t"
    format_printf "Brew Doctor Recovery Menu" "yellow" "bold"
    printf "\n"
    printf "\t1. HomeBrew Update 1\n"
    printf "\t2. HomeBrew Update 2\n"
    printf "\t3. Brew Doctor Recovery\n"
    printf "\t0. Exit Menu\n\n"
    printf "\t\tEnter an Option: "
    # Read entire input instead of just one character
    read option
    # Remove any whitespace
    option=$(echo $option | tr -d '[:space:]')
}

# Main loop
while true; do
    menu
    hit_any_key=false
    # Check if input is a valid number
    if [[ $option =~ ^[0-9]+$ ]]; then
        case $option in
            0)
                break 
                ;;
            1)
                brewdocs1
                hit_any_key=true
                ;;
            2)
                brewdocs2
                hit_any_key=true
                ;;
            3)
                brewdocs3
		hit_any_key=true
                ;;
            *)
                clear
                warning_printf "Sorry, wrong selection"
                hit_any_key=true
                ;;
        esac
    # Handle empty input (Enter key)
    elif [[ -z "$option" ]]; then
        break
    else
        clear
        warning_printf "Please enter a valid number"
        hit_any_key=true
    fi
    # Check if the user should be prompted to hit any key to continue
    if [[ "$hit_any_key" == "true" ]]; then
        printf "\n\n\t\t\t"
        # Use printf with info formatting but without newline
        printf '\033[1;34m%s\033[0m' "ℹ️  Press any key to continue"
        read -k 1 line
    fi
done

clear
# Reset Trap Ctl-C
trap INT

#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

# Standard Message Formatting Library and Functions
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

function zdialogbox {
	clear
	~/bin/zTests/zDialogBox.sh
# Display Exit Status Value Set Based Upon Dialog Box Button Clicked
	echo $?
}

function zjqjsonconfig {
	clear
	~/bin/zTests/zJQJsonConfig.sh
}

function zjsonconfig {
	clear
	~/bin/zTests/zJsonConfig.sh
}

function zjqjsonutil {
	clear
	~/bin/zTests/zJQJsonUtil.sh
}

function zpassfromshortcuts {
	clear
	~/bin/zTests/zPassFromShortcuts.sh
}

function zuserinput {
	clear
	~/bin/zTests/zUserinput.sh
}

function zdaysofmonth {
	clear
	~/bin/zTests/zDaysOfMonth.sh
}

function zselectoption {
	clear
	~/bin/zTests/zSelectOption.sh
}

function menu {
    clear
    printf "\n"
    printf "\t\t\t"
    format_printf "Test Menu" "yellow" "bold"
    printf "\n"
    printf "\t1. zDialogBox\n"
    printf "\t2. zJQJsonConfig\n"
    printf "\t3. zJsonConfig\n"
    printf "\t4. zJQJsonUtil\n"
    printf "\t5. zPassFromShortcuts\n"
    printf "\t6. zUserinput\n"
    printf "\t7. zDaysOfMonth\n"
    printf "\t8. zSelectOption\n"
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
		zdialogbox
		hit_any_key=true
		;;
	    2)
		zjqjsonconfig
		hit_any_key=true
		;;
	    3)
		zjsonconfig
		hit_any_key=true
		;;
	    4)
		zjqjsonutil
		hit_any_key=true
		;;
	    5)
		zpassfromshortcuts
		hit_any_key=true
		;;
	    6)
		zuserinput
		hit_any_key=true
		;;
	    7)
		zdaysofmonth
		hit_any_key=true
		;;
	    8)
		zselectoption
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

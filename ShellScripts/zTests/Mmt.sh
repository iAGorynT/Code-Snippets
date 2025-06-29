#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

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
	echo
	echo -e "\t\t\t\033[33;1mTest Menu\033[0m\n"
	echo -e "\t1. zDialogBox"
	echo -e "\t2. zJQJsonConfig"
	echo -e "\t3. zJsonConfig"
	echo -e "\t4. zJQJsonUtil"
	echo -e "\t5. zPassFromShortcuts"
	echo -e "\t6. zUserinput"
	echo -e "\t7. zDaysOfMonth"
	echo -e "\t8. zSelectOption"
	echo -e "\t0. Exit Menu\n\n"
	echo -en "\t\tEnter an Option: "
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
                echo "Sorry, wrong selection"
                hit_any_key=true
                ;;
        esac
    # Handle empty input (Enter key)
    elif [[ -z "$option" ]]; then
        break
    else
        clear
        echo "Please enter a valid number"
        hit_any_key=true
    fi
    # Check if the user should be prompted to hit any key to continue
    if [[ "$hit_any_key" == "true" ]]; then
        echo -en "\n\n\t\t\tPress any key to continue"
        read -k 1 line
    fi
done

clear
# Reset Trap Ctl-C
trap INT

#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function clispeed {
	clear
	echo 'Speedtest in progress...'; speedtest -p yes
}

function netq {
	clear
	networkQuality -v
}

function menu {
	clear
	echo
	echo -e "\t\t\t\033[33;1mNetwork Menu\033[0m\n"
	echo -e "\t1. Internet Speed Test"
	echo -e "\t2. Apple Network Quality Test"
	echo -e "\t0. Exit Menu\n\n"
	echo -en "\t\tEnter an Option: "
        # Read entire input instead of just one character
        read option
        # Remove any whitespace
        option=$(echo $option | tr -d '[:space:]')
}

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
	        clispeed
		hit_any_key=true
		;;
	    2)
	        netq
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
        echo -en "\n\n\t\t\tHit any key to continue"
        read -k 1 line
    fi
done

clear
# Reset Trap Ctl-C
trap INT

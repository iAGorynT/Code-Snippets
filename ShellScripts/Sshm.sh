#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function setsshpw {
	clear
	Sshpw.sh
}

function turnsshon {
	clear
	sudo systemsetup -setremotelogin on
	sudo systemsetup -getremotelogin
}

function turnsshoff {
	clear
	sudo systemsetup -setremotelogin off
	sudo systemsetup -getremotelogin
}

function showsshstat {
	clear
	sudo systemsetup -getremotelogin
}

function listsshdir {
	clear
	Sshdir.sh
}

function menu {
	clear
	echo
	echo -e "\t\t\t\033[33;1mSSH Menu\033[0m\n"
	echo -e "\t1. Set SSH Password"
	echo -e "\t2. Turn SSH On"
	echo -e "\t3. Turn SSH Off"
	echo -e "\t4. SSH Status"
	echo -e "\t5. SSH Directory File Contents"
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
	        setsshpw 
		hit_any_key=true
		;;
	    2)
	        turnsshon 
		hit_any_key=true
		;;
	    3)
	        turnsshoff 
		hit_any_key=true
		;;
	    4)
	        showsshstat 
		hit_any_key=true
		;;
	    5)
	        listsshdir 
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

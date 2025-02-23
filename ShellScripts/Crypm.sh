#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function enigma {
	clear
        # Run Enigma Shortcuts App
        echo "Info" "Standby... Enigma Running"
        shortcuts run "Enigma"
        echo "Info" "Enigma Complete..."
        continue
}

function cryptxt {
	Cryptxt.sh
}

function crypvault {
	Crypvault.sh
}

function gauthenticator {
	clear
	echo "Gauth Authenticator..."
	echo
	gauth
}

function menu {
	clear
	echo
	echo -e "\t\t\t\033[33;1mCrypt Menu\033[0m\n"
	echo -e "\t1. Enigma Shortcut"
	echo -e "\t2. SSL Cryptxt"
	echo -e "\t3. SSL Crypvault"
	echo -e "\t4. Gauth Authenticator"
	echo -e "\t0. Exit Menu\n\n"
	echo -en "\t\tEnter an Option: "
        # Read entire input instead of just one character
        read option
        # Remove any whitespace
        option=$(echo $option | tr -d '[:space:]')
}

while true; do
    menu
    # Check if input is a valid number
    if [[ $option =~ ^[0-9]+$ ]]; then
        case $option in
	    0)
	        break 
		;;
	    1)
	        enigma
		;;
	    2)
	        cryptxt
		;;
	    3)
	        crypvault
		;;
	    4)
	        gauthenticator
		;;
            *)
                clear
                echo "Sorry, wrong selection"
                ;;
	esac
    # Handle empty input (Enter key)
    elif [[ -z "$option" ]]; then
        break
    else
        clear
        echo "Please enter a valid number"
    fi
    echo -en "\n\n\t\t\tHit any key to continue"
    read -k 1 line
done

clear
# Reset Trap Ctl-C
trap INT

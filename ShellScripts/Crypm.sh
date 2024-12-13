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

function menu {
	clear
	echo
	echo -e "\t\t\tCrypt Menu\n"
	echo -e "\t1. Enigma Shortcut"
	echo -e "\t2. SSL Cryptxt"
	echo -e "\t3. SSL Crypvault"
	echo -e "\t0. Exit Menu\n\n"
	echo -en "\t\tEnter an Option: "
	read -k 1 option
# Test If Return / Enter Key Pressed; Replace Linefeed Character With Empty Character
        if [[ "$option" == *$'\n'* ]]; then
            option=""
        fi
}

while [ 1 ]
do
	menu
	case $option in
	0)
	break ;;

	1)
	enigma;;

	2)
	cryptxt;;

	3)
	crypvault;;

# Return / Enter Key Pressed
        "")
        break ;;

	*)
	clear
	echo "Sorry, wrong selection";;
	esac
	echo -en "\n\n\t\t\tHit any key to continue"
	read -k 1 line
done
clear

# Reset Trap Ctl-C
trap INT

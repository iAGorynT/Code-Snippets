#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function infomenu {
	clear
	Infom.sh
}

function netmenu {
	clear
	Netm.sh
}

function sshmenu {
	clear
	Sshm.sh
}

function crypmenu {
	clear
	Crypm.sh
}

function menu {
	clear
	echo
	echo -e "\t\t\t\033[33;1mOps Menu\033[0m\n"
	echo -e "\t1. Info Menu"
	echo -e "\t2. Network Menu"
	echo -e "\t3. SSH Menu"
	echo -e "\t4. Crypt Menu"
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
	infomenu;;

	2)
	netmenu;;

	3)
	sshmenu;;

	4)
	crypmenu;;

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

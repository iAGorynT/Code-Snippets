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
	echo -e "\t\t\tNetwork Menu\n"
	echo -e "\t1. Internet Speed Test"
	echo -e "\t2. Apple Network Quality Test"
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
	clispeed;;

	2)
	netq;;

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

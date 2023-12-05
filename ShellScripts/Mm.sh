#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function brewm {
	clear
	brewm.sh
}

function opsm {
	clear
	opsm.sh
}

function ipm {
	clear
	ipm.sh
}

function testm {
	clear
	~/bin/zTests/mmt.sh
}

function menu {
	clear
	echo
	echo -e "\t\t\tMain Menu\n"
	echo -e "\t1. Homebrew Menu"
	echo -e "\t2. Ops Menu"
	echo -e "\t3. Iperf3 Menu"
	echo -e "\t4. Test Menu"
	echo -e "\t0. Exit Menu\n\n"
	echo -en "\t\tEnter an Option: "
	read -k 1 option
}

while [ 1 ]
do
	menu
	case $option in
	0)
	break ;;

	1)
	brewm;;

	2)
	opsm;;

	3)
	ipm;;

	4)
	testm;;

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

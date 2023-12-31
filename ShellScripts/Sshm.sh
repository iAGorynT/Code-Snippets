#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function setsshpw {
	clear
	sshpw.sh
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
	sshdir.sh
}

function menu {
	clear
	echo
	echo -e "\t\t\tSSH Command Menu\n"
	echo -e "\t1. Set SSH Password"
	echo -e "\t2. Turn SSH On"
	echo -e "\t3. Turn SSH Off"
	echo -e "\t4. SSH Status"
	echo -e "\t5. SSH Directory File Contents"
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
	setsshpw ;;

	2)
	turnsshon ;;

	3)
	turnsshoff ;;

	4)
	showsshstat ;;

	5)
	listsshdir ;;

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

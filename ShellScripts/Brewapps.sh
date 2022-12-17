#!/bin/bash
# Using bash instead of zsh becasue of menu command incompatibility.

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function brewappsu {
	clear
	echo "*** Brew Apps Unformatted..."
	echo " "
	brew desc --eval-all $(brew list)
}

function brewappsf {
	clear
	echo "*** Brew Apps Formatted..."
	echo " "
	brew desc --eval-all $(brew list) | awk 'gsub(/^([^:]*?)\s*:\s*/,"&=")' | column -s "=" -t
}

function menu {
	clear
	echo
	echo -e "\t\t\tBrew Apps Menu\n"
	echo -e "\t1. Brew Apps Unformatted"
	echo -e "\t2. Brew Apps Formatted"
	echo -e "\t0. Exit Menu\n\n"
	echo -en "\t\tEnter an Option: "
	read -n 1 option
}

while [ 1 ]
do
	menu
	case $option in
	0)
	break ;;

	1)
	brewappsu ;;

	2)
	brewappsf ;;

	*)
	clear
	echo "Sorry, wrong selection";;
	esac
	echo -en "\n\n\t\t\tHit any key to continue"
	read -n 1 line
done
clear

# Reset Trap Ctl-C
trap INT

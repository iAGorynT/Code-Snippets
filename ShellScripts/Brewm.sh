#!/bin/bash
# Using bash instead of zsh becasue of menu command incompatibility.

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function brewit {
	clear
	brewit.sh
}

function brewlist {
	clear
	echo "Brew List..."
	echo " "
	brew list
}

function brewdep {
	clear
	echo "Brew Dependencies..."
	echo " "
	brew deps --formula --installed
}

function viewbrewfile {
# Display Brew File Contents
	clear
	echo "Brew File..."
	echo " "
	cat ~/Brewfile
	echo -en "\n\n\t\t\tHit any key to view App Descriptions"
	read -n 1 line
# Display Installed Brew File App Descriptions
	clear
	echo "App Decriptions..."
	echo " "
	echo "* btop - Activity Monitor"
	echo "* iperf3 - Internal Network Speed Test"
	echo "* mosh - Mobile Shell; Use Instead of SSH for High Latency Connections"
	echo "* speedtest-cli - Internet Speed Test"
	echo "* balenaetcher - ISO Burner"
	echo "* github - Version Control Manager"
	echo "* macvim - Code Editor"
}

function brewdocm {
	clear
	brewdocm.sh
}

function mvexplore {
	clear
	mvexplore.sh 
}

function menu {
	clear
	echo
	echo -e "\t\t\tHomeBrew Menu\n"
	echo -e "\t1. Brewit"
	echo -e "\t2. Brew List"
	echo -e "\t3. Brew Dependencies"
	echo -e "\t4. View Brewfile"
	echo -e "\t5. Brew Doctor"
	echo -e "\t6. MacVim Explore"
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
	brewit;;

	2)
	brewlist;;

	3)
	brewdep;;

	4)
	viewbrewfile;;

	5)
	brewdocm;;

	6)
	mvexplore;;

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

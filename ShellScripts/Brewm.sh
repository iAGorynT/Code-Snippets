#!/bin/zsh

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
	brew deps --formula --installed | more
}

function viewbrewfile {
# Display Brew File Contents
	clear
	echo "Brew File..."
	echo " "
	cat ~/Brewfile
	echo -en "\n\n\t\t\tHit any key to view App Descriptions"
	read -k 1 line
# Display Selected Brew File App Descriptions
	clear
	echo "App Descriptions..."
	echo " "
	brewapps.sh
}

function brewapps {
	clear
	echo "Brew App Listing..."
	echo " "
# Formatted Listing
	brew desc --eval-all $(brew list) | awk 'gsub(/^([^:]*?)\s*:\s*/,"&=")' | column -s "=" -t | more
# For Unformatted Listing
# brew desc --eval-all $(brew list)
}

function brewtap {
	clear
	echo "Brew Taps..."
	echo "Directories (usually Git Repositories) of formulae (CLI based Apps),"
	echo "Casks (GUI based Apps), and/or external commands."
	echo " "
	brew tap
}

function brewdocm {
	clear
	brewdocm.sh
}

function brewautom {
	clear
	brewautom.sh
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
	echo -e "\t5. Brew App Listing"
	echo -e "\t6. Brew Taps"
	echo -e "\t7. Brew Doctor"
	echo -e "\t8. Brew Autoupdate"
	echo -e "\t9. MacVim Explore"
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
	brewit;;

	2)
	brewlist;;

	3)
	brewdep;;

	4)
	viewbrewfile;;

	5)
	brewapps;;

	6)
	brewtap;;

	7)
	brewdocm;;

	8)
	brewautom;;

	9)
	mvexplore;;

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

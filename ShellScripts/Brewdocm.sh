#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

# Activate Function Library
source $HOME/ShellScripts/FunctionLib.sh

function brewdocs1 {
	clear
	format_echo "HomeBrew Update 1/3..." "brew" 1
	echo " "
	brew update
	echo " "
	echo "Fix any errors and continue with Step 2"
	echo "cmd-doubleclick for troubleshooting info: https://docs.brew.sh/Troubleshooting"	
}

function brewdocs2 {
	clear
	format_echo "HomeBrew Update 2/3..." "brew" 1
	echo " "
	brew update
	echo " "
	echo "Fix any errors and continue with Step 3"
	echo "cmd-doubleclick for troubleshooting info: https://docs.brew.sh/Troubleshooting"	
}

function brewdocs3 {
	clear
	format_echo "Brew Doctor 3/3..." "brew" 1
	echo " "
	brew doctor
	echo " "
	echo "Fix any errors to complete Brew Doctor Recovery"
	echo "cmd-doubleclick for troubleshooting info: https://docs.brew.sh/Troubleshooting"
}

function menu {
	clear
	echo
	echo -e "\t\t\tBrew Doctor Recovery Menu\n"
	echo -e "\t1. HomeBrew Update 1"
	echo -e "\t2. HomeBrew Update 2"
	echo -e "\t3. Brew Doctor Recovery"
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
	brewdocs1 ;;

	2)
	brewdocs2 ;;

	3)
	brewdocs3 ;;

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

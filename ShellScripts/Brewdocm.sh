#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatEcho.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    echo "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

function brewdocs1 {
	clear
	format_echo "HomeBrew Update 1/3..." "none" "brew"
	echo " "
	brew update
	echo " "
	info_echo "Fix any errors and continue with Step 2"
	info_echo "cmd-doubleclick for troubleshooting info: https://docs.brew.sh/Troubleshooting"
}

function brewdocs2 {
	clear
	format_echo "HomeBrew Update 2/3..." "none" "brew"
	echo " "
	brew update
	echo " "
	info_echo "Fix any errors and continue with Step 3"
	info_echo "cmd-doubleclick for troubleshooting info: https://docs.brew.sh/Troubleshooting"
}

function brewdocs3 {
	clear
	format_echo "Brew Doctor 3/3..." "none" "brew"
	echo " "
	brew doctor
	echo " "
	info_echo "Fix any errors to complete Brew Doctor Recovery"
	info_echo "cmd-doubleclick for troubleshooting info: https://docs.brew.sh/Troubleshooting"
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

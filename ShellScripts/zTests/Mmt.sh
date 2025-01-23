#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function zdialogbox {
	clear
	~/bin/zTests/zDialogBox.sh
# Display Exit Status Value Set Based Upon Dialog Box Button Clicked
	echo $?
}

function zjqjsonconfig {
	clear
	~/bin/zTests/zJQJsonConfig.sh
}

function zjsonconfig {
	clear
	~/bin/zTests/zJsonConfig.sh
}

function zjqjsonutil {
	clear
	~/bin/zTests/zJQJsonUtil.sh
}

function zpassfromshortcuts {
	clear
	~/bin/zTests/zPassFromShortcuts.sh
}

function zuserinput {
	clear
	~/bin/zTests/zUserinput.sh
}

function zdaysofmonth {
	clear
	~/bin/zTests/zDaysOfMonth.sh
}

function zselectoption {
	clear
	~/bin/zTests/zSelectOption.sh
}

function menu {
	clear
	echo
	echo -e "\t\t\t\033[33;1mTest Menu\033[0m\n"
	echo -e "\t1. zDialogBox"
	echo -e "\t2. zJQJsonConfig"
	echo -e "\t3. zJsonConfig"
	echo -e "\t4. zJQJsonUtil"
	echo -e "\t5. zPassFromShortcuts"
	echo -e "\t6. zUserinput"
	echo -e "\t7. zDaysOfMonth"
	echo -e "\t8. zSelectOption"
	echo -e "\t0. Exit Menu\n\n"
	echo -en "\t\tEnter an Option: "
        # Read entire input instead of just one character
        read option
        # Remove any whitespace
        option=$(echo $option | tr -d '[:space:]')
}

while [ 1 ]
do
	menu
	case $option in
	0)
	break ;;

	1)
	zdialogbox;;

	2)
	zjqjsonconfig;;

	3)
	zjsonconfig;;

	4)
	zjqjsonutil;;

	5)
	zpassfromshortcuts;;

	6)
	zuserinput;;

	7)
	zdaysofmonth;;

	8)
	zselectoption;;

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

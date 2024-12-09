#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function hname {
	clear
	Hname.sh
}

function penv {
	clear
	echo "Environment Variables..."
	echo " "
	printenv | more
}

function sver {
	clear
	Versions.sh
}

function pkgu {
	clear
	echo "Installed Packages..."
	echo " "
	pkgutil --pkgs | more
}

function pall {
	clear
	echo "System Information..."
	echo " "
	particulars -a
}

function clispeed {
	clear
	echo 'Speedtest in progress...'; speedtest -p yes
}

function netq {
	clear
	networkQuality -v
}

function sshmenu {
	clear
	Sshm.sh
}

function menu {
	clear
	echo
	echo -e "\t\t\tOps Menu\n"
	echo -e "\t1. Hostname"
	echo -e "\t2. Environment Variables"
	echo -e "\t3. Software Versions"
	echo -e "\t4. Installed Packages"
	echo -e "\t5. System Information"
	echo -e "\t6. Internet Speed Test"
	echo -e "\t7. Apple Network Quality Test"
	echo -e "\t8. SSH Command Menu"
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
	hname;;

	2)
	penv;;

	3)
	sver;;

	4)
	pkgu;;

	5)
	pall;;

	6)
	clispeed;;

	7)
	netq;;

	8)
	sshmenu;;

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

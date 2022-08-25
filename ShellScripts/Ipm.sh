#!/bin/bash
# Using bash instead of zsh becasue of menu command incompatibility.

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function iperfstartserver {
	clear
	ipss.sh
}

function iperfclient2server {
	clear
	ipc2s.sh
}

function iperfserver2client {
	clear
	ips2c.sh 
}

function ooklainternettest {
	clear
	echo "Starting Ookla Internet Speedtest App..."
	open -a Speedtest.app
}

function menu {
	clear
	echo
	echo -e "\t\t\tiPerf Network Speedtest Menu\n"
	echo -e "\t1. Start iPerf Server"
	echo -e "\t2. Client to Server Speedtest"
	echo -e "\t3. Server to Client Speedtest"
	echo -e "\t4. Ookla Internet Speedtest"
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
	iperfstartserver ;;

	2)
	iperfclient2server ;;

	3)
	iperfserver2client ;;

	4)
	ooklainternettest ;;

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

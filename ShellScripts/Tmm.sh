#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function tmsetpw {
	clear
	Sshpw.sh
}

function tmbackup {
	clear
	Tmb.sh
}

function tmsnapshots {
	clear
	Tms.sh
}

function tmdeletesnapshots {
	clear
	sudo TmDelete.sh
}

function menu {
	clear
	echo
	echo -e "\t\t\t\033[33;1mTime Machine Menu\033[0m\n"
	echo -e "\t1. Set Time Machine Password"
	echo -e "\t2. Run Time Machine Backup"
	echo -e "\t3. List Snapshots"
	echo -e "\t4. Delete Snapshots"
	echo -e "\t0. Exit Menu\n\n"
	echo -en "\t\tEnter an Option: "
        # Read entire input instead of just one character
        read option
        # Remove any whitespace
        option=$(echo $option | tr -d '[:space:]')
}

while true; do
    menu
    # Check if input is a valid number
    if [[ $option =~ ^[0-9]+$ ]]; then
        case $option in
	    0)
	        break 
		;;
	    1)
	        tmsetpw
		;;
	    2)
	        tmbackup
		;;
	    3)
	        tmsnapshots
		;;
	    4)
	        tmdeletesnapshots
		;;
            *)
                clear
                echo "Sorry, wrong selection"
                ;;
	esac
    # Handle empty input (Enter key)
    elif [[ -z "$option" ]]; then
        break
    else
        clear
        echo "Please enter a valid number"
    fi
    echo -en "\n\n\t\t\tHit any key to continue"
    read -k 1 line
done

clear
# Reset Trap Ctl-C
trap INT

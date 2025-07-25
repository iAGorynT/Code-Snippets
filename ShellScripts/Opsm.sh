#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

function infomenu {
	clear
	Infom.sh
}

function netmenu {
	clear
	Netm.sh
}

function sshmenu {
	clear
	Sshm.sh
}

function crypmenu {
	clear
	Crypm.sh
}

function tmmenu {
	clear
	Tmm.sh
}

function menu {
    clear
    echo
    echo -e "\t\t\t\033[33;1mOps Menu\033[0m\n"
    echo -e "\t1. Info Menu"
    echo -e "\t2. Network Menu"
    echo -e "\t3. SSH Menu"
    echo -e "\t4. Crypt Menu"
    echo -e "\t5. Time Machine Menu"
    echo -e "\t0. Exit Menu\n\n"
    echo -en "\t\tEnter an Option: "
    # Read entire input instead of just one character
    read option
    # Remove any whitespace
    option=$(echo $option | tr -d '[:space:]')
}

while true; do
    menu
    hit_any_key=false
    # Check if input is a valid number
    if [[ $option =~ ^[0-9]+$ ]]; then
        case $option in
            0)
                break 
                ;;
            1)
                infomenu
                ;;
            2)
                netmenu
                ;;
            3)
                sshmenu
                ;;
            4)
                crypmenu
                ;;
            5)
                tmmenu
                ;;
            *)
                clear
                echo "Sorry, wrong selection"
                hit_any_key=true
                ;;
        esac
    # Handle empty input (Enter key)
    elif [[ -z "$option" ]]; then
        break
    else
        clear
        echo "Please enter a valid number"
        hit_any_key=true
    fi
    # Check if the user should be prompted to hit any key to continue
    if [[ "$hit_any_key" == "true" ]]; then
        echo -en "\n\n\t\t\tPress any key to continue"
        read -k 1 line
    fi
done

clear
# Reset Trap Ctl-C
trap INT

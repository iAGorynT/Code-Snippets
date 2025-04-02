#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

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
    echo -e "\t\t\t\033[33;1miPerf3 Menu\033[0m\n"
    echo -e "\t1. Start iPerf Server"
    echo -e "\t2. Client to Server Speedtest"
    echo -e "\t3. Server to Client Speedtest"
    echo -e "\t4. Ookla Internet Speedtest"
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
                iperfstartserver
		hit_any_key=true
                ;;
            2)
                iperfclient2server
		hit_any_key=true
                ;;
            3)
                iperfserver2client
		hit_any_key=true
                ;;
            4)
                ooklainternettest
		hit_any_key=true
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
        echo -en "\n\n\t\t\tHit any key to continue"
        read -k 1 line
    fi
done

clear
# Reset Trap Ctl-C
trap INT

#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

# Standard Message Formatting Library and Functions
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

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
    printf "\n"
    printf "\t\t\t"
    format_printf "iPerf3 Menu" "yellow" "bold"
    printf "\n"
    printf "\t1. Start iPerf Server\n"
    printf "\t2. Client to Server Speedtest\n"
    printf "\t3. Server to Client Speedtest\n"
    printf "\t4. Ookla Internet Speedtest\n"
    printf "\t0. Exit Menu\n\n"
    printf "\t\tEnter an Option: "
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
                warning_printf "Sorry, wrong selection"
		hit_any_key=true
                ;;
        esac
    # Handle empty input (Enter key)
    elif [[ -z "$option" ]]; then
        break
    else
        clear
        warning_printf "Please enter a valid number"
	hit_any_key=true
    fi
    # Check if the user should be prompted to hit any key to continue
    if [[ "$hit_any_key" == "true" ]]; then
        printf "\n\n\t\t\t"
        # Use printf with info formatting but without newline
        printf '\033[1;34m%s\033[0m' "ℹ️  Press any key to continue"
        read -k 1 line
    fi
done

clear
# Reset Trap Ctl-C
trap INT

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

function brewit {
    clear
    brewit.sh
}

function brewlist {
    clear
    format_echo "Brew List..." "yellow" "bold"
    echo
    brew list
}

function brewdep {
    clear
    format_echo "Brew Dependencies..." "yellow" "bold"
    echo
    brew deps --formula --installed | more
}

function viewbrewfile {
    # Display Brew File Contents
    clear
    format_echo "Brew File..." "yellow" "bold"
    echo
    cat ~/Brewfile
    echo -en "\n\n\t\t\tHit any key to view App Descriptions"
    read -k 1 line
    # Display Selected Brew File App Descriptions
    clear
    brewapps.sh
}

function brewapps {
    clear
    format_echo "Brew App Listing..." "yellow" "bold"
    echo
    # Formatted Listing and redirect stderr to /dev/null to suppress errors
    brew desc --eval-all $(brew list) 2>/dev/null | awk 'gsub(/^([^:]*?)\s*:\s*/,"&=")' | column -s "=" -t | more
    # For Unformatted Listing
    # brew desc --eval-all $(brew list)
}

function brewtap {
    clear
    format_echo "Brew Taps..." "yellow" "bold"
    info_echo "Directories (usually Git Repositories) of formulae (CLI based Apps),"
    info_echo "Casks (GUI based Apps), and/or external commands."
    echo
    brew tap
}

function brewdocm {
    clear
    brewdocm.sh
}

function brewautom {
    clear
    brewautom2.sh
}

function mvexplore {
    clear
    mvedit.sh
}

function brewappuninstaller {
    clear
    brewappuninstall.sh
}

function menu {
    clear
    echo
    echo -e "\t\t\t\033[33;1mHomeBrew Menu\033[0m\n"
    echo -e "\t1. Brewit"
    echo -e "\t2. Brew List"
    echo -e "\t3. Brew Dependencies"
    echo -e "\t4. View Brewfile"
    echo -e "\t5. Brew App Listing"
    echo -e "\t6. Brew Taps"
    echo -e "\t7. Brew Doctor"
    echo -e "\t8. Brew Autoupdate"
    echo -e "\t9. MacVim Explore"
    echo -e "\t10. Brew App Uninstaller"
    echo -e "\t0. Exit Menu\n\n"
    echo -en "\t\tEnter an Option: "
    # Read entire input instead of just one character
    read option
    # Remove any whitespace
    option=$(echo $option | tr -d '[:space:]')
}

# Main loop
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
                brewit
                hit_any_key=true
                ;;
            2)
                brewlist
                hit_any_key=true
                ;;
            3)
                brewdep
                hit_any_key=true
                ;;
            4)
                viewbrewfile
                hit_any_key=true
                ;;
            5)
                brewapps
                hit_any_key=true
                ;;
            6)
                brewtap
                hit_any_key=true
                ;;
            7)
                brewdocm
                ;;
            8)
                brewautom
                ;;
            9)
                mvexplore
		sleep 1
                ;;
            10)
                brewappuninstaller
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

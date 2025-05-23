#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

function pyup {
    clear
    PyUpdate.sh
}

function pipup {
    clear
    PipUpdate.sh
}

function vimup {
    clear
    VimUpdate.sh
}

function cleanup {
    clear
    Cleanup.sh
}

function cleanupclaude {
    clear
    CleanupClaude.sh
}

function menu {
    clear
    echo
    echo -e "\t\t\t\033[33;1mUtility Menu\033[0m\n"
    echo -e "\t1. Python Update"
    echo -e "\t2. Pip Package Update"
    echo -e "\t3. Vim Plugin Update"
    echo -e "\t4. Disk Cleanup"
    echo -e "\t5. Cleanup Claude Workspace"
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
    if [[ $option =~ ^[0-9]+$ ]]; then
        case $option in
            0)
                break 
                ;;
            1)
                pyup
                hit_any_key=true
                ;;
            2)
                pipup
                hit_any_key=true
                ;;
            3)
                vimup
                hit_any_key=true
                ;;
            4)
                cleanup
                hit_any_key=true
                ;;
            5)
                cleanupclaude
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

#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function brewm {
    clear
    brewm.sh
}

function opsm {
    clear
    opsm.sh
}

function devm {
    clear
    devm.sh
}

function ipm {
    clear
    ipm.sh
}

function testm {
    clear
    $HOME/ShellScripts/zTests/mmt.sh
}

function menu {
    clear
    echo
    echo -e "\t\t\t\033[33;1mMain Menu\033[0m\n"
    echo -e "\t1. Homebrew Menu"
    echo -e "\t2. Ops Menu"
    echo -e "\t3. Dev Menu"
    echo -e "\t4. Iperf3 Menu"
    echo -e "\t5. Test Menu"
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
    # Check if input is a valid number
    if [[ $option =~ ^[0-9]+$ ]]; then
        case $option in
            0)
                break 
                ;;
            1)
                brewm
                ;;
            2)
                opsm
                ;;
            3)
                devm
                ;;
            4)
                ipm
                ;;
            5)
                testm
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

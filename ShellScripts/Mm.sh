#!/bin/zsh
# Main menu script using FLibFormatPrintf.sh for formatting
# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'warning_printf "\nCtrl-C will not terminate $0."'  INT

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

function util {
    clear
    utilm.sh
}

function testm {
    clear
    $HOME/ShellScripts/zTests/mmt.sh
}

function menu {
    clear
    printf "\n"
    format_printf "\t\t\tMain Menu" "yellow" "bold"
    printf "\n"
    format_printf "\t1. Homebrew Menu"
    format_printf "\t2. Ops Menu"
    format_printf "\t3. Dev Menu"
    format_printf "\t4. Iperf3 Menu"
    format_printf "\t5. Utility Menu"
    format_printf "\t6. Test Menu"
    format_printf "\t0. Exit Menu"
    printf "\n\n"
    printf "\t\tEnter an Option: "
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
                util
                ;;
            6)
                testm
                ;;
            *)
                clear
                error_printf "Sorry, wrong selection"
                hit_any_key=true
                ;;
        esac
    # Handle empty input (Enter key)
    elif [[ -z "$option" ]]; then
        break
    else
        clear
        error_printf "Please enter a valid number"
        hit_any_key=true
    fi
    # Check if the user should be prompted to hit any key to continue
    if [[ "$hit_any_key" == "true" ]]; then
        printf "\n\n\t\t\tPress any key to continue"
        read -k 1 line
    fi
done

clear
# Reset Trap Ctl-C
trap INT

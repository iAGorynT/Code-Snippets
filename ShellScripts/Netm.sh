#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

# Standard Message Formatting Library and Functions
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

function clispeed {
    clear
    info_printf 'Speedtest in progress...'
    speedtest -p yes
}

function netq {
    clear
    networkQuality -v
}

function menu {
    clear
    printf "\n"
    printf "\t\t\t"
    format_printf "Network Menu" "yellow" "bold"
    printf "\n"
    printf "\t1. Internet Speed Test\n"
    printf "\t2. Apple Network Quality Test\n"
    printf "\t0. Exit Menu\n\n"
    printf "\t\tEnter an Option: "
    # Read Single-key input 
    read -k1 option
    # Read remaining digits
    local num="$option"
    local next_char
    while true; do
    # Time Delay increased from 0.1 to 0.3 to give user more time for entry
    read -s -t 0.3 -k1 next_char 2>/dev/null || break
    if [[ "$next_char" =~ [0-9] ]]; then
        num="${num}${next_char}"
    else
        break
    fi
    done
    # Remove any whitespace
    option=$(echo $num | tr -d '[:space:]')
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
                clispeed
                hit_any_key=true
                ;;
            2)
                netq
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

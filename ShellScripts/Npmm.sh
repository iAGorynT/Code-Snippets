#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

# Source function library with error handling

SCRIPT_DIR="${0:a:h}"
FORMAT_LIBRARY="$SCRIPT_DIR/FLibFormatPrintf.sh"

if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    printf "Error: Required library not found: %s\n" "$FORMAT_LIBRARY" >&2
    printf "Searched in script directory: %s\n" "$SCRIPT_DIR" >&2
    exit 1
fi

source "$FORMAT_LIBRARY"

function npmlist {
    clear
    NpmList.sh
}

function npmoutdated {
    clear
    NpmOutdated.sh
}

function npmglobalupdate {
    clear
    NpmGlobalUpdates.sh
}

function npmglobaluninstall {
    clear
    NpmGlobalUninstall.sh
}

function npmglobaluninstalltest {
    clear
    NpmGlobalUninstall.sh --test
}

function menu {
    clear
    printf "\n"
    printf "\t\t\t"
    format_printf "NPM Menu" "yellow" "bold" "underline"
    printf "\n"
    printf "\t1. Global NPM Packages List\n"
    printf "\t2. Outdated Global NPM Packages\n"
    printf "\t3. NPM Global Package Updates\n"
    printf "\t4. Uninstall NPM Global Package\n"
    printf "\t5. Test Uninstall NPM Global Package\n"
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

while true; do
    menu
    hit_any_key=false
    if [[ $option =~ ^[0-9]+$ ]]; then
        case $option in
            0)
                break 
                ;;
            1)
                npmlist
                hit_any_key=true
                ;;
            2)
                npmoutdated
                hit_any_key=true
                ;;
            3)
                npmglobalupdate
                hit_any_key=true
                ;;
            4)
                npmglobaluninstall
                hit_any_key=true
                ;;
            5)
                npmglobaluninstalltest
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

#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'printf "\nCtrl-C will not terminate %s.\n" "$0"'  INT

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2; exit 1; }
source "$FORMAT_LIBRARY"

function brewit {
    clear
    brewit.sh
}

function brewlist {
    clear
    format_printf "Brew List..." "yellow" "bold"
    printf "\n"
    brew list
}

function brewdep {
    clear
    format_printf "Brew Dependencies..." "yellow" "bold"
    printf "\n"
    brew deps --formula --installed | more
}

function viewbrewfile {
    # Display Brew File Contents
    clear
    format_printf "Brew File..." "yellow" "bold"
    printf "\n"
    cat ~/Brewfile
    printf "\n\n\t\t\t"
    # Use printf with info formatting but without newline
    printf '\033[1;34m%s\033[0m' "ℹ️  Press any key to view App Descriptions"
    read -k 1 line
    # Display Selected Brew File App Descriptions
    clear
    brewapps.sh
}

function brewapps {
    clear
    format_printf "Brew App Listing..." "yellow" "bold"
    printf "\n"
    # Formatted Listing and redirect stderr to /dev/null to suppress errors
    brew desc --eval-all $(brew list) 2>/dev/null | awk 'gsub(/^([^:]*?)\s*:\s*/,"&=")' | column -s "=" -t | more
    # For Unformatted Listing
    # brew desc --eval-all $(brew list)
}

function brewtap {
    clear
    format_printf "Brew Taps..." "yellow" "bold"
    printf "\n"
    info_printf "Directories (usually Git Repositories) of formulae (CLI based Apps),"
    info_printf "Casks (GUI based Apps), and/or external commands."
    printf "\n"
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
    printf "\n"
    printf "\t\t\t\033[33;1mHomeBrew Menu\033[0m\n\n"
    printf "\t1. Brewit\n"
    printf "\t2. Brew List\n"
    printf "\t3. Brew Dependencies\n"
    printf "\t4. View Brewfile\n"
    printf "\t5. Brew App Listing\n"
    printf "\t6. Brew Taps\n"
    printf "\t7. Brew Doctor\n"
    printf "\t8. Brew Autoupdate\n"
    printf "\t9. MacVim Explore\n"
    printf "\t10. Brew App Uninstaller\n"
    printf "\t0. Exit Menu\n\n\n"
    printf "\t\tEnter an Option: "
    # Read entire input instead of just one character
    read option
    # Remove any whitespace
    option=$(printf %s "$option" | tr -d '[:space:]')
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

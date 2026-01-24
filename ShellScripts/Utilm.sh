#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

# Standard Message Formatting Library and Functions
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

function vimup {
    clear
    VimUpdate.sh
}

function javaup {
    clear
    JavaUpdate.sh
}

function npmup {
    clear
    NpmUpdate.sh
}

function cleanup {
    clear
    Cleanup.sh
}

function cleanupclaude {
    clear
    CleanupClaude.sh
}

function updateallpack {
    clear
    UtilAllPack.sh
}

function cleanupalldisk {
    clear
    UtilAllDisk.sh
}

function menu {
    clear
    printf "\n"
    printf "\t\t\t"
    format_printf "Utility Menu" "yellow" "bold"
    printf "\n"
    printf "\t1. Vim Plugin Update\n"
    printf "\t2. Java Update\n"
    printf "\t3. Npm Package Update\n"
    printf "\t4. Disk Cleanup\n"
    printf "\t5. Cleanup Claude Workspace\n"
    printf "\n"
    printf "\t"
    format_printf "Bundle Updates" "cyan" "underline"
    printf "\t6. Update All Packages\n"
    printf "\t7. Cleanup All Disks\n"
    printf "\n"
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
    if [[ $option =~ ^[0-9]+$ ]]; then
        case $option in
            0)
                break 
                ;;
            1)
                vimup
                hit_any_key=true
                ;;
            2)
                javaup
                hit_any_key=true
                ;;
            3)
                npmup
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
            6)
                updateallpack
                hit_any_key=true
                ;;
            7)
                cleanupalldisk
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

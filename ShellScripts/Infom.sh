#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

# Standard Message Formatting Library and Functions
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Initialize flag variable
CLOSE_FINDER_WINDOWS=0

function close_finder_windows() {
    local window_name="$1"
    osascript <<EOF > /dev/null 2>&1
    tell application "System Events"
        tell process "Finder"
            set allWindows to (every window whose name contains "$window_name")
            repeat with w in allWindows
                try
                    if exists w then
                        click button 1 of w
                    end if
                end try
            end repeat
        end tell
    end tell
EOF
}

function hname {
    clear
    Hname.sh
    CLOSE_FINDER_WINDOWS=0
}

function penv {
    clear
    format_printf "Environment Variables..." "yellow" "bold"
    printf "\n"
    printenv | more
    CLOSE_FINDER_WINDOWS=0
}

function sver {
    clear
    Versions.sh
    CLOSE_FINDER_WINDOWS=0
}

function pkgu {
    clear
    format_printf "Installed Packages..." "yellow" "bold"
    printf "\n"
    pkgutil --pkgs | more
    CLOSE_FINDER_WINDOWS=0
}

function pall {
    clear
    format_printf "Particulars Information..." "yellow" "bold"
    printf "\n"
    particulars -a
    CLOSE_FINDER_WINDOWS=0
}

function ghstats {
    clear
    format_printf "GitHub Stats..." "yellow" "bold"
    printf "\n"
    # Determine if 'gitfetch' is available, otherwise display message
    if command -v gitfetch >/dev/null 2>&1; then
        gitfetch
    else
        warning_printf "'gitfetch' command not found. Please install it to view GitHub stats." 
    fi
}

function dstats {
    clear
    Dstats.sh
    CLOSE_FINDER_WINDOWS=1
}

function menu {
    clear
    printf "\n"
    printf "\t\t\t"
    format_printf "Info Menu" "yellow" "bold"
    printf "\n"
    printf "\t1. Hostname\n"
    printf "\t2. Environment Variables\n"
    printf "\t3. Software Versions\n"
    printf "\t4. Installed Packages\n"
    printf "\t5. Particulars Information\n"
    printf "\t6. GitHub Stats\n"
    printf "\t7. Disk Stats\n"
    printf "\t0. Exit Menu\n\n"
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
                hname
                hit_any_key=true
                ;;
            2)
                penv
                hit_any_key=true
                ;;
            3)
                sver
                hit_any_key=true
                ;;
            4)
                pkgu
                hit_any_key=true
                ;;
            5)
                pall
                hit_any_key=true
                ;;
            6)
                ghstats
                hit_any_key=true
                ;;
            7)
                dstats
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
    if [ $CLOSE_FINDER_WINDOWS -eq 1 ]; then
        close_finder_windows "Macintosh HD"
    fi
    CLOSE_FINDER_WINDOWS=0
done

clear
# Reset Trap Ctl-C
trap INT

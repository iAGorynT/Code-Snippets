#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

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
    echo "Environment Variables..."
    echo " "
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
    echo "Installed Packages..."
    echo " "
    pkgutil --pkgs | more
    CLOSE_FINDER_WINDOWS=0
}

function pall {
    clear
    echo "Particulars Information..."
    echo " "
    particulars -a
    CLOSE_FINDER_WINDOWS=0
}

function dstats {
    clear
    Dstats.sh
    CLOSE_FINDER_WINDOWS=1
}

function menu {
    clear
    echo
    echo -e "\t\t\t\033[33;1mInfo Menu\033[0m\n"
    echo -e "\t1. Hostname"
    echo -e "\t2. Environment Variables"
    echo -e "\t3. Software Versions"
    echo -e "\t4. Installed Packages"
    echo -e "\t5. Particulars Information"
    echo -e "\t6. Disk Stats"
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
                dstats
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
    if [ $CLOSE_FINDER_WINDOWS -eq 1 ]; then
        close_finder_windows "Macintosh HD"
    fi
    CLOSE_FINDER_WINDOWS=0
done

clear
# Reset Trap Ctl-C
trap INT

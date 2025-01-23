#!/bin/zsh

# Set strict error handling
set -euo pipefail

# Trap Ctrl-C and prevent it from terminating the script
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

# Define color constants for better readability
readonly COLOR_BLUE='36'    # Cyan/Blue
readonly COLOR_GREEN='32'   # Green
readonly COLOR_YELLOW='33'  # Yellow
readonly COLOR_RED='31'     # Red
readonly COLOR_BOLD='1'     # Bold formatting

# Define variables using readonly to prevent accidental modification
readonly USERNAME="${USERNAME:-$(whoami)}"
readonly TEMPLATE_FILE="$HOME/Launchd/Launchd.plist"
readonly USER_PLIST_NAME="com.bin.${USERNAME}.brewit.plist"
readonly GREP_NAME="com.bin.${USERNAME}.brewit"
readonly USER_PLIST="$HOME/Launchd/${USER_PLIST_NAME}"
readonly LAUNCH_AGENT_FOLDER="$HOME/Library/LaunchAgents"
readonly LAUNCH_AGENT_PLIST="${LAUNCH_AGENT_FOLDER}/${USER_PLIST_NAME}"
readonly LAUNCH_AGENT_LOG_FOLDER="$HOME/Library/Logs/${GREP_NAME}"

# Improved error handling function with line number
function error() {
    echo "Error on line $1" >&2
    exit 1
}
trap 'error $LINENO' ERR

# Function to check if launchd agent is active
function is_agent_active() {
    launchctl list | grep -q "$GREP_NAME"
}

# Function to print status message with color
function print_status() {
    local color="$1"
    local message="$2"
    echo -e "\033[${COLOR_BOLD};${color}m${message}\033[0m"
}

# Function to empty log file
function empty_log() {
    echo "Logfile Emptied:  $(date)" > "$1"
    echo >> "$1"
    print_status "${COLOR_GREEN}" "Log File Emptied."
}

# Function to check the status of the Brew autoupdate service
function autoupdate_status() {
    clear
    print_status "${COLOR_YELLOW}" "Brew Autoupdate Status..."
    echo

    if is_agent_active; then
        print_status "${COLOR_GREEN}" "Launchd Agent is active."
    else
        print_status "${COLOR_YELLOW}" "Warning: Launchd Agent is not active."
    fi

    # Check for log file
    local autolog=""
    if [[ -f "$LAUNCH_AGENT_PLIST" ]]; then
        autolog=$(plutil -extract StandardOutPath raw "$LAUNCH_AGENT_PLIST" 2>/dev/null || echo "")
#       autolog=$(/usr/libexec/PlistBuddy -c "Print :StandardOutPath" "$LAUNCH_AGENT_PLIST" 2>/dev/null || echo "")
    fi

    if [[ -f "$autolog" ]]; then
   	# Extract hours and minutes individually, suppressing errors
        local hour=0
        local minutes=0
        hour=$(plutil -extract StartCalendarInterval.Hour raw -o - $LAUNCH_AGENT_PLIST 2>/dev/null | \
		grep -o '^[0-9]*')
        minutes=$(plutil -extract StartCalendarInterval.Minute raw -o - $LAUNCH_AGENT_PLIST 2>/dev/null | \
		grep -o '^[0-9]*')
        # Check if both hour and minutes were successfully extracted (non-empty and all digits)
        if [[ -n $hour && -n $minutes && $hour =~ ^[0-9]+$ && $minutes =~ ^[0-9]+$ ]]; then
            # Format and print the output with zero-padding using echo
            hour=$(printf "%02d" "$hour")
            minutes=$(printf "%02d" "$minutes")
            echo "Runs Daily: ${hour}:${minutes}"
        fi 
        echo -en "\n\n\t\t\tPress any key to view the Autoupdate Log"
        read -k 1
        clear
        print_status "${COLOR_BLUE}" "Brew Autoupdate Log Listing..."
        echo

        # Process log file using awk for better performance
        awk '
            /^(Brew Update,)/ {
                if (!first) print "====>";
                first = 0;
            }
            {print}
        ' "$autolog" | less

        # Confirm empty log execution
        while true; do
            read yn\?"Empty Log (Y/N): "
            case $yn in
                [Yy]* ) empty_log "$autolog"; break;;
                [Nn]* ) break;;
                * ) echo "Please answer yes (Y) or no (N).";;
            esac
        done
    else
        print_status "${COLOR_RED}" "Autoupdate log file not found."
    fi
}

# Function to load Homebrew Autoupdate
function load_autoupdate() {
    clear
    print_status "${COLOR_BLUE}" "Loading Homebrew Autoupdate..."
    echo

    # Confirm Execution
    while true; do
        read yn\?"Confirm (Y/N): "
        case $yn in
            [Yy]* ) echo; break;;
            [Nn]* ) return;;
            * ) echo "Please answer yes (Y) or no (N).";;
        esac
    done

    # Verify Launchd Agent isn't already active
    if is_agent_active; then
        print_status "${COLOR_YELLOW}" "Launchd Agent is already loaded and active."
	return
    fi

    [[ -f $TEMPLATE_FILE ]] || error ${LINENO} "Launchd.plist file not found!"

    # Create directories if they don't exist
    mkdir -p "$LAUNCH_AGENT_FOLDER" "$LAUNCH_AGENT_LOG_FOLDER"

    # Loop until a valid hour is entered
    while true; do
        read UHOUR\?"What hour? (0-23): "
        # Validate the input
        if [[ $UHOUR =~ ^([0-9]|1[0-9]|2[0-3])$ ]]; then
            echo "Hour: $UHOUR"
	    echo
            break
        else
            echo "Invalid input. Please enter a number between 0 and 23."
        fi
    done

    # Use parameter expansion for safer substitution of both $UNAME and $UHOUR
    sed "s|\$UNAME|${USERNAME//\//\\/}|g" "$TEMPLATE_FILE" > "$USER_PLIST" || 
        error ${LINENO} "Failed to create user-specific plist file!"
    plutil -replace StartCalendarInterval.Hour -integer "$UHOUR" "$USER_PLIST" || 
        error ${LINENO} "Failed to modify plist file!"
#    /usr/libexec/PlistBuddy -c "Set :StartCalendarInterval:Hour $UHOUR" \
#        "$USER_PLIST" || error ${LINENO} "Failed to modify plist file!"

    print_status "${COLOR_GREEN}" "User-specific Launchd.plist file created: $USER_PLIST"

    cp "$USER_PLIST" "$LAUNCH_AGENT_PLIST" ||
        error ${LINENO} "Failed to copy plist to LaunchAgents folder!"

    print_status "${COLOR_GREEN}" "User plist copied to Library LaunchAgents folder..."

    if launchctl load "$LAUNCH_AGENT_PLIST"; then
        print_status "${COLOR_GREEN}" "Launchd Agent ${LAUNCH_AGENT_PLIST} loaded successfully."
        if is_agent_active; then
            print_status "${COLOR_GREEN}" "Launchd Agent is active."
        else
            print_status "${COLOR_YELLOW}" "Warning: Launchd Agent may not be active."
        fi
    else
        error ${LINENO} "Failed to load Launchd Agent."
    fi
}

# Function to unload Homebrew Autoupdate
function unload_autoupdate() {
    clear
    print_status "${COLOR_BLUE}" "Unloading/Removing Homebrew Autoupdate..."
    echo

    # Confirm Execution
    while true; do
        read yn\?"Confirm (Y/N): "
        case $yn in
            [Yy]* ) echo; break;;
            [Nn]* ) return;;
            * ) echo "Please answer yes (Y) or no (N).";;
        esac
    done

    if ! [[ -f "$LAUNCH_AGENT_PLIST" ]]; then
        print_status "${COLOR_YELLOW}" "No Launchd Agent found to unload."
        return
    fi

    if launchctl unload "$LAUNCH_AGENT_PLIST"; then
        print_status "${COLOR_GREEN}" "Launchd Agent ${LAUNCH_AGENT_PLIST} unloaded successfully."
        
        if is_agent_active; then
            error ${LINENO} "Launchd Agent is still active."
        else
            print_status "${COLOR_GREEN}" "Removing Launchd Agent..."
            rm -f "$LAUNCH_AGENT_PLIST"
            print_status "${COLOR_GREEN}" "Removing Launchd Agent log folder..."
            rm -rf "$LAUNCH_AGENT_LOG_FOLDER"
        fi
    else
        error ${LINENO} "Failed to unload Launchd Agent."
    fi
}

# Function to display the main menu - Fixed for zsh compatibility
function show_menu() {
    clear
    echo
    print_status "${COLOR_BLUE}" "\t\t\tBrew Autoupdate Menu\n"
    
    echo -e "\t1. Check Autoupdate Status"
    echo -e "\t2. Load Autoupdate"
    echo -e "\t3. Unload Autoupdate"
    echo -e "\t0. Exit"
    echo -en "\t\tEnter an Option: "

    # Read entire input instead of just one character
    read option
    # Remove any whitespace
    option=$(echo $option | tr -d '[:space:]')
    echo
}

# Main loop
while true; do
    show_menu
    # Check if input is a valid number
    if [[ $option =~ ^[0-9]+$ ]]; then
        case $option in
            0) break ;;
            1) autoupdate_status ;;
            2) load_autoupdate ;;
            3) unload_autoupdate ;;
            *) clear; print_status "${COLOR_RED}" "\n\tSorry, wrong selection" ;;
        esac
    # Handle empty input (Enter key)
    elif [[ -z "$option" ]]; then
        break
    else
        clear
        print_status "${COLOR_RED}" "\n\tPlease enter a valid number"
    fi
    echo -en "\n\tPress any key to continue"
    read -k 1
done

# Reset Ctrl-C behavior to default
trap - INT
clear

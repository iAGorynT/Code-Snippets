#!/bin/zsh

# Trap Ctrl-C and prevent it from terminating the script.
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

# Function to check the status of the Brew autoupdate service
function autoupdatestatus {
    clear
    echo "Brew Autoupdate Status..."
    echo

    # Define variables for file paths
    userplistname="com.bin.${USERNAME}.brewit.plist"
    grepname="com.bin.${USERNAME}.brewit"
    launchagentfolder="$HOME/Library/LaunchAgents"
    launchagentplist="${launchagentfolder}/${userplistname}"

    # Check if the launchd agent is active
    if launchctl list | grep -q "$grepname"; then
        echo "Launchd Agent is active."
    else
        echo "Warning: Launchd Agent may not be active."
    fi

    # Check if the Brew autoupdate log file exists
    if [[ -f "$launchagentplist" ]]; then
        # Extract the log file path from the plist file using PlistBuddy
        autolog=$(/usr/libexec/PlistBuddy -c "Print :StandardOutPath" "$launchagentplist")
    fi

    # If the log file exists, display its contents
    if [[ -f "$autolog" ]]; then
        echo -en "\n\n\t\t\tPress any key to view the Autoupdate Log"
        read -k 1
        clear
        echo "Brew Autoupdate Log Listing..."
        echo

        # Temporary file for storing formatted log output
        temp_file=$(mktemp)

        # Boolean to indicate the start of a new log entry
        newlog=true

        # Process each line of the log file
        while IFS= read -r line; do
            # Detect new log entries based on the pattern
            if [[ "$line" =~ ^(Brew Update,) ]]; then
                if $newlog; then
                    # Add a separator line before new entries
                    echo "====>" >> "$temp_file"
                    newlog=false
                else
                    newlog=true
                fi
            fi
            # Append the current line to the temporary file
            echo "$line" >> "$temp_file"
        done < "$autolog"

        # Display the formatted log using 'more' for paging
        cat "$temp_file" | more

        # Clean up the temporary file
        rm "$temp_file"
    fi
}

# Function to load the Brew autoupdate service
function autoupdateload {
    clear
    echo "Load Brew Autoupdate..."
    echo

    while true; do
        read yn\?"Confirm (Y/N): "
        case $yn in
            [Yy]* ) echo; brewitload.sh; break;;
            [Nn]* ) break;;
            * ) echo "Please answer yes (Y) or no (N).";;
        esac
    done
}

# Function to unload the Brew autoupdate service
function autoupdateunload {
    clear
    echo "Unload Brew Autoupdate..."
    echo

    while true; do
        read yn\?"Confirm (Y/N): "
        case $yn in
            [Yy]* ) echo; brewitunload.sh; break;;
            [Nn]* ) break;;
            * ) echo "Please answer yes (Y) or no (N).";;
        esac
    done
}

# Function to display the main menu
function menu {
    clear
    echo
    echo -e "\t\t\tBrew Autoupdate Menu\n"
    echo -e "\t1. Check Autoupdate Status"
    echo -e "\t2. Load Autoupdate"
    echo -e "\t3. Unload Autoupdate"
    echo -e "\t0. Exit Menu\n\n"
    echo -en "\tEnter your choice: "
    read -k 1 option

    # Handle Return/Enter key as an empty input
    [[ "$option" == $'\n' ]] && option=""
}

# Main loop for the script
while true; do
    menu
    case $option in
        0)  # Exit the script
            break ;;
        1)  # Display autoupdate status
            autoupdatestatus ;;
        2)  # Load the autoupdate service
            autoupdateload ;;
        3)  # Unload the autoupdate service
            autoupdateunload ;;
        "") # Exit when Enter is pressed
            break ;;
        *)  # Invalid option handling
            clear
            echo "Invalid selection. Please try again." ;;
    esac
    echo -en "\n\n\tPress any key to continue"
    read -k 1
done

# Reset Ctrl-C behavior to default
trap - INT
clear


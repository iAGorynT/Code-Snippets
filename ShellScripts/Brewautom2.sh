#!/bin/zsh

# Trap Ctrl-C and prevent it from terminating the script.
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

# Set up or remove Homebrew Autoupdate using Launchd

# Define variables for file paths
template_file="$HOME/Launchd/Launchd.plist"
userplistname="com.bin.${USERNAME}.brewit.plist"
grepname="com.bin.${USERNAME}.brewit"
userplist="$HOME/Launchd/${userplistname}"
launchagentfolder="$HOME/Library/LaunchAgents"
launchagentplist="${launchagentfolder}/${userplistname}"
launchagentlogfolder="$HOME/Library/Logs/${grepname}"

# Function to print error message and exit
function exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Function to check the status of the Brew autoupdate service
function autoupdate_status {
    clear
    echo "Brew Autoupdate Status..."
    echo

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
    else
        echo "Autoupdate log file not found."
    fi
}

# Function to load Homebrew Autoupdate
function load_autoupdate() {
    clear
    echo "Loading Homebrew Autoupdate..."
    echo

    # Confirm Execution
    while true; do
        read yn\?"Confirm (Y/N): "
        case $yn in
            [Yy]* ) echo; break;;
            [Nn]* ) return; break;;
            * ) echo "Please answer yes (Y) or no (N).";;
        esac
    done

    # Check if the template file exists
    if [[ ! -f $template_file ]]; then
        exit_with_error "Launchd.plist file not found!"
    fi

    # Create LaunchAgents directory if it does not exist
    mkdir -p "$launchagentfolder"

    # Replace $UNAME placeholder with the $USERNAME value and create the user-specific plist
    if sed "s|\$UNAME|$USERNAME|g" "$template_file" > "$userplist"; then
        echo "User-specific Launchd.plist file created: $userplist"
    else
        exit_with_error "Failed to create the user-specific plist file!"
    fi
    echo

    # Copy the user-specific plist file to LaunchAgents folder
    if cp "$userplist" "$launchagentplist"; then
        echo "User plist copied to Library LaunchAgents folder..."
    else
        exit_with_error "Failed to copy ${userplist} to ${launchagentfolder}!"
    fi
    echo

    # Load the user-specific plist file using launchctl
    if launchctl load "$launchagentplist"; then
        echo "Launchd Agent ${launchagentplist} loaded successfully."
        # Verify if the agent was loaded
        if launchctl list | grep -q "$grepname"; then
            echo "Launchd Agent is active."
        else
            echo "Warning: Launchd Agent may not be active."
        fi
    else
        exit_with_error "Failed to load Launchd Agent."
    fi
}

# Function to unload Homebrew Autoupdate
function unload_autoupdate() {
    clear
    echo "Unloading/Removing Homebrew Autoupdate..."
    echo

    # Confirm Execution
    while true; do
        read yn\?"Confirm (Y/N): "
        case $yn in
            [Yy]* ) echo; break;;
            [Nn]* ) return; break;;
            * ) echo "Please answer yes (Y) or no (N).";;
        esac
    done

    # Unload the user-specific plist file using launchctl
    if launchctl unload "$launchagentplist"; then
        echo "Launchd Agent ${launchagentplist} unloaded successfully."
        echo
        # Verify if the agent was unloaded
        if launchctl list | grep -q "$grepname"; then
            exit_with_error "Launchd Agent is still active."
        else
            # Remove user-specific plist file
            echo "Removing Launchd Agent..."
            rm "$launchagentplist"
            # Remove user-specific log file
            echo "Removing Launchd Agent log file..."
            rm -R "$launchagentlogfolder"
        fi
    else
        exit_with_error "Failed to unload Launchd Agent."
    fi
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
            autoupdate_status ;;
        2)  # Load the autoupdate service
            load_autoupdate ;;
        3)  # Unload the autoupdate service
            unload_autoupdate ;;
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


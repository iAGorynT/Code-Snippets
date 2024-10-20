#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function autoupdatestatus {
	clear
	echo "Brew Autoupdate Status..."
	echo
# Define variables for file paths
	userplistname="com.bin.${USERNAME}.brewit.plist"
	grepname="com.bin.${USERNAME}.brewit"
	launchagentfolder="$HOME/Library/LaunchAgents"
	launchagentplist="${launchagentfolder}/${userplistname}"
# Check Status of launchd agent
        if launchctl list | grep -q "$grepname"; then
            echo "Launchd Agent is active."
        else
            echo "Warning: Launchd Agent may not be active."
        fi
#	echo
# Autoupdate Log Listing
# If Brew Autoupdate Logfile Exist, Show Contents
	if test -f "$launchagentplist"; then
# Extract Keyvalue From Plist File Using PlistBuddy
	    autolog=$(/usr/libexec/PlistBuddy -c "Print :StandardOutPath" $launchagentplist)
	fi
# Check if the Autoupdate Log file exists
	if [ -f "$autolog" ]; then
	    echo -en "\n\n\t\t\tHit any key to view Autoupdate Log Listing"
	    read -k 1 line
	    clear
	    echo "Brew Autoupdate Log Listing..."
	    echo
# Temporary file to store the modified content
	    temp_file=$(mktemp)
# Loop through each line of the file
	    while IFS= read -r line; do
# Check if the line starts with any of the specified days
#               if [[ "$line" =~ ^(Mon|Tue|Wed|Thu|Fri|Sat|Sun) ]]; then
# Add a blank line before the line
#                   echo "" >> "$temp_file"
#               fi
# Append the original line to the temporary file
	        echo "$line" >> "$temp_file"
	    done < "$autolog"
# Display Reformatted Autoupdate Logfile
	    cat "$temp_file" | more
	fi
}

function autoupdateload {
	clear
	echo "Load Brew Autoupdate..."
	echo
        
	while true; do
	    read yn\?"Yy / Nn: "
	    case $yn in
	        [Yy]* ) echo; brewitload.sh; break;;
	        [Nn]* ) break;;
	        * ) echo "Please answer yes or no.";;
	    esac
	done
}

function autoupdateunload {
	clear
	echo "Unload Brew Autoupdate..."
	echo

	while true; do
	    read yn\?"Yy / Nn: "
	    case $yn in
	        [Yy]* ) echo; brewitunload.sh; break;;
	        [Nn]* ) break;;
	        * ) echo "Please answer yes or no.";;
	    esac
	done
}

function menu {
	clear
	echo
	echo -e "\t\t\tBrew Autoupdate Menu\n"
	echo -e "\t1. Autoupdate Status"
	echo -e "\t2. Load Autoupdate"
	echo -e "\t3. Unload Autoupdate"
	echo -e "\t0. Exit Menu\n\n"
	echo -en "\t\tEnter an Option: "
	read -k 1 option
# Test If Return / Enter Key Pressed; Replace Linefeed Character With Empty Character
        if [[ "$option" == *$'\n'* ]]; then
            option=""
        fi
}

while [ 1 ]
do
	menu
	case $option in
	0)
	break ;;

	1)
	autoupdatestatus ;;

	2)
	autoupdateload ;;

	3)
	autoupdateunload ;;

# Return / Enter Key Pressed
        "")
        break ;;

	*)
	clear
	echo "Sorry, wrong selection";;
	esac
	echo -en "\n\n\t\t\tHit any key to continue"
	read -k 1 line
done
clear

# Reset Trap Ctl-C
trap INT

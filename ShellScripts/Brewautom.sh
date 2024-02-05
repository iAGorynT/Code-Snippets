#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function autoupdatestatus {
	clear
	echo "Brew Autoupdate Status..."
	echo
	brew autoupdate status
	echo "Brew Autoupdate Log Listing..."
	echo
# Brew Autoupdate Plist File
	autoplist=$HOME'/Library/LaunchAgents/com.github.domt4.homebrew-autoupdate.plist'  
# If Brew Autoupdate Logfile Exist, Show Contents
	if test -f "$autoplist"
	    then  
# Extract Keyvalue From Plist File Using PlistBuddy
	    autolog=$(/usr/libexec/PlistBuddy -c "Print :StandardOutPath" $autoplist)
	    cat $autolog | more
	fi
}

function autoupdatestart {
	clear
	echo "Starting Brew Autoupdate..."
	echo
	brew autoupdate start --upgrade --greedy --cleanup --enable-notification --immediate --quiet
}

function autoupdatestop {
	clear
	echo "Brew Autoupdate Stop..."
	echo
	while true; do
	    read yn\?"Yy / Nn: "
	    case $yn in
	        [Yy]* ) echo; brew autoupdate stop; break;;
	        [Nn]* ) break;;
	        * ) echo "Please answer yes or no.";;
	    esac
	done
}

function autoupdatedelete {
	clear
	echo "Brew Autoupdate Delete..."
	echo
	while true; do
	    read yn\?"Yy / Nn: "
	    case $yn in
	        [Yy]* ) echo; brew autoupdate delete; break;;
	        [Nn]* ) break;;
	        * ) echo "Please answer yes or no.";;
	    esac
	done
}

function autoupdatehelp {
	clear
	echo "Brew Autoupdate Help..."
	echo
	brew autoupdate --help | more
}

function menu {
	clear
	echo
	echo -e "\t\t\tBrew Autoupdate Menu\n"
	echo -e "\t1. Autoupdate Status"
	echo -e "\t2. Start Autoupdate"
	echo -e "\t3. Stop Autoupdate"
	echo -e "\t4. Delete Autoupdate"
	echo -e "\t5. Autoupdate Help" 
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
	autoupdatestart ;;

	3)
	autoupdatestop ;;

	4)
	autoupdatedelete ;;

	5)
	autoupdatehelp ;;

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

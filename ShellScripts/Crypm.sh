#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function enigma {
	clear
        # Run Enigma Shortcuts App
        echo "Info:" "Standby... Enigma Running"
        shortcuts run "Enigma"
        echo "Info:" "Enigma Complete..."
        continue
}

function cryptxt {
	Cryptxt.sh
}

function crypvault {
	Crypvault.sh
}

function gauthenticator {
	Gauth.sh
}

function gmanager {
	GauthMgr.sh
}

function otppy {
	python3 ~/PythonCode/otp_generator.py
}

function otpzsh {
	ZshOtpGenerator.sh
}

function otpzshmgr {
	ZshOtpManager.sh
}

function menu {
	clear
	echo
	echo -e "\t\t\t\033[33;1mCrypt Menu\033[0m\n"
	echo -e "\t1. Enigma Shortcut"
	echo -e "\t2. SSL Cryptxt"
	echo -e "\t3. SSL Crypvault"
	echo -e "\t4. Gauth Authenticator"
	echo -e "\t5. Gauth OTP Manager"
	echo -e "\t6. Python Authenticator / OTP Manager"
	echo -e "\t7. Zsh Authenticator"
	echo -e "\t8. Zsh OTP Manager"
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
	        enigma
		hit_any_key=true
		;;
	    2)
	        cryptxt
		hit_any_key=true
		;;
	    3)
	        crypvault
		hit_any_key=true
		;;
	    4)
	        gauthenticator
		hit_any_key=true
		;;
	    5)
	        gmanager
		hit_any_key=true
		;;
	    6)
	        otppy
		hit_any_key=true
		;;
	    7)
	        otpzsh
		hit_any_key=true
		;;
	    8)
	        otpzshmgr
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
done

clear
# Reset Trap Ctl-C
trap INT

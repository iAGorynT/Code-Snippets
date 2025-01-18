#!/bin/zsh

# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e  "\nCtrl-C will not terminate $0."'  INT

function devsync {
	clear
	Devsync.sh
}

function ghdesktop {
	clear
        open -a "GitHub Desktop.app"
	echo "Running GitHub Desktop App..."
}

function crypvault {
	clear
        # select Vault Type
        echo "Select Vault Type..."
        echo 
        # Define common vaults
	local vault_name
	local common_vaults
        common_vaults=("VaultMGR" "GitMGR")
        select vault_type in "${common_vaults[@]}"; do
            case $vault_type in
                VaultMGR) vault_name="vmgr"; break;;
                GitMGR)   vault_name="gmgr"; break;;
            esac
        done
	Crypvault.sh $vault_name
}

function crypmenu {
	clear
	Crypm.sh
}

function menu {
	clear
	echo
	echo -e "\t\t\t\033[33;1mDev Menu\033[0m\n"
	echo -e "\t1. Devsync"
	echo -e "\t2. GitHub Desktop"
	echo -e "\t3. Crypvault"
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
	devsync;;

	2)
	ghdesktop;;

	3)
	crypvault;;

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

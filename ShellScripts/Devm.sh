#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

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
    echo "Select Vault Type..."
    echo 
    local vault_name
    local common_vaults=("VaultMGR" "GitMGR")
    select vault_type in "${common_vaults[@]}"; do
        case $vault_type in
            VaultMGR) vault_name="vmgr"; break;;
            GitMGR)   vault_name="gmgr"; break;;
        esac
    done
    Crypvault.sh $vault_name
}

function bsum {
    clear
    BackupSummary.sh
}

function menu {
    clear
    echo
    echo -e "\t\t\t\033[33;1mDev Menu\033[0m\n"
    echo -e "\t1. Devsync (Dev to Local Repo)"
    echo -e "\t2. GitHub Desktop (Local Repo to GitHub)"
    echo -e "\t3. Crypvault (Local Repo to iCloud)"
    echo -e "\t4. Backup Summary"
    echo -e "\t0. Exit Menu\n\n"
    echo -en "\t\tEnter an Option: "
    # Read entire input instead of just one character
    read option
    # Remove any whitespace
    option=$(echo $option | tr -d '[:space:]')
}

while true; do
    menu
    if [[ $option =~ ^[0-9]+$ ]]; then
        case $option in
            0)
                break 
                ;;
            1)
                devsync
                ;;
            2)
                ghdesktop
                ;;
            3)
                crypvault
                ;;
            4)
                bsum
                ;;
            *)
                clear
                echo "Sorry, wrong selection"
                ;;
        esac
    # Handle empty input (Enter key)
    elif [[ -z "$option" ]]; then
        break
    else
        clear
        echo "Please enter a valid number"
    fi
    echo -en "\n\n\t\t\tHit any key to continue"
    read -k 1 line
done

clear
# Reset Trap Ctl-C
trap INT

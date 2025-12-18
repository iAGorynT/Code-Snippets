#!/bin/zsh
# Trap Ctl-C and Require a Menu Selection to Exit Script
trap 'echo -e "\nCtrl-C will not terminate $0."' INT

# Standard Message Formatting Library and Functions
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

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

function reptext {
    clear
    ReplaceShellText.sh
}

function autofork {
    clear
    AutoForkClone.sh
}

function mbat {
    clear
    MBat.sh
}

function hlist {
    clear
    HashList.sh
}

function menu {
    clear
    printf "\n"
    printf "\t\t\t"
    format_printf "Dev Menu" "yellow" "bold"
    printf "\n"
    printf "\t1. Devsync (Dev to Local Repo)\n"
    printf "\t2. GitHub Desktop (Local Repo to GitHub)\n"
    printf "\t3. Crypvault (Local Repo to iCloud)\n"
    printf "\t4. Backup Summary\n"
    printf "\n"
    printf "\t\033[4;36mCoding Updates\033[0m\n"
    printf "\t5. Replace Shellscript Text\n"
    printf "\t6. Auto Fork and Clone Repo\n"
    printf "\t7. Bat Menu Viewer\n"
    printf "\t8. Hash Key Report\n"
    printf "\n"
    printf "\t0. Exit Menu\n\n"
    printf "\t\tEnter an Option: "
    # Read entire input instead of just one character
    read option
    # Remove any whitespace
    option=$(echo $option | tr -d '[:space:]')
}

while true; do
    menu
    hit_any_key=false
    if [[ $option =~ ^[0-9]+$ ]]; then
        case $option in
            0)
                break 
                ;;
            1)
                devsync
                hit_any_key=true
                ;;
            2)
                ghdesktop
                hit_any_key=true
                ;;
            3)
                crypvault
                hit_any_key=true
                ;;
            4)
                bsum
                hit_any_key=true
                ;;
            5)
                reptext
                hit_any_key=true
                ;;
            6)
                autofork
                hit_any_key=true
                ;;
            7)
                mbat
                hit_any_key=true
                ;;
            8)
                hlist
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
done

clear
# Reset Trap Ctl-C
trap INT

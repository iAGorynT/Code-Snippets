#!/bin/zsh

# Save passed Vault Type if supplied
# Note: Parameter value should be "vmgr", "gmgr", or left blank
vaultpassed=$1

# Function to clear screen and display header
display_header() {
    clear
    echo "OpenSSL Vault Encrypt / Decrypt"
    echo " "
}

# Function to get filename from JSON config with improved error handling and flexibility
get_filename_from_config() {
    # Check if correct number of arguments is provided
    if [[ $# -ne 2 ]]; then
        echo "Usage: get_filename_from_config <config_file> <key>" >&2
        return 1
    fi

    local config_file="$1"
    local key="$2"

    # Check if config file exists
    if [[ ! -f "$config_file" ]]; then
        echo "Error: Config file '$config_file' not found" >&2
        return 1
    fi

    # Prefer jq if available (faster and more robust)
    if command -v jq >/dev/null 2>&1; then
        # Use jq to extract the value, handling potential errors
        local filename
        filename=$(jq -e -r ".$key // empty" "$config_file")
        
        # Check if jq extraction was successful
        if [[ -z "$filename" ]]; then
            echo "Error: Unable to find key '$key' in config file" >&2
            return 1
        fi
        
        echo "$filename"
        return 0
    fi

    # Fallback method using grep and sed if jq is not available
    local filename
    filename=$(grep -o "\"$key\": *\"[^\"]*\"" "$config_file" | sed -n "s/.*: *\"\(.*\)\"/\1/p")
    
    if [[ -z "$filename" ]]; then
        echo "Error: Unable to find key '$key' in config file using fallback method" >&2
        return 1
    fi

    echo "$filename"
}

# Main loop
while true; do
    display_header

    # Set Default Directory To Desktop
    cd "$HOME/Desktop"

    # Define common actions
    common_actions=("Encrypt" "Decrypt" "View")
    
    # Add "GitSync" for non-vmgr case
    if [[ $vaultpassed != "vmgr" ]]; then
        common_actions+=("GitSync")
    fi

    # Add remaining common actions
    common_actions+=("Backup" "Config" "Reset" "Quit")

    echo "Select Action..."
    echo " "
    select action in "${common_actions[@]}"; do
        case $action in
            Encrypt)  action="enc"; break;;
            Decrypt)  action="dec"; break;;
            View)     action="view"; break;;
            GitSync)  action="sync"; break;;
            Backup)   action="back"; break;;
            Config)   action="conf"; break;;
            Reset)    action="rset"; break;;
            Quit)     action="quit"; break;;
        esac
    done

    # Perform the selected action
    case $action in
        quit)
            # Check if user wants to quit
            if [[ $action == "quit" ]]; then
                echo " "
                echo "OpenSSL Vault Enc/Dec Completed"
                exit 0
            fi
            ;;
        rset)
            # Reset settings to All Vaults
            vaultpassed=''
            echo " "
            echo "Settings reset to All Vaults..."
            read -k 1
            continue
            ;;
        view)
            # Display Warning message
            if [[ $action == "view" ]]; then
            # Display a warning message when viewing
                osascript -e 'display dialog "WHEN VIEWING, DO NOT UPDATE SELECTED VAULT-Changes will not be saved!" with title "Caution When Viewing" with icon caution buttons {"OK"} default button "OK"' >/dev/null 2>&1
            fi
            ;;
        conf)
            # Run ConfigFILES Shortcuts App
            echo " "
            echo "Standby... ConfigFILES Running"
            shortcuts run "ConfigFILES"
            echo "ConfigFILES Complete..."
            echo " "
            continue
            ;;
    esac

    # Select Vault Type
    if [ -z "$vaultpassed" ]; then
        echo " "
        echo "Select Vault Type..."
        echo " "
        # Define common vaults
        if [[ $action != "sync" ]]; then
            common_vaults=("VaultMGR" "GitMGR")
        else
            common_vaults=("GitMGR")
        fi
        select vault_type in "${common_vaults[@]}"; do
            case $vault_type in
                VaultMGR) vault_name="vmgr"; break;;
                GitMGR)   vault_name="gmgr"; break;;
            esac
        done
    else
        vault_name=$vaultpassed
    fi
    echo " "

    # Set Vault Configuration File Location
    config_dir="$HOME/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/Config Files"
    if [[ $vault_name == "vmgr" ]]; then
        config_file="$config_dir/vaultmgr_config.json"
    elif [[ $vault_name == "gmgr" ]]; then
        config_file="$config_dir/gitmgr_config.json"
    fi
    
    # Determine Type of Encryption Used on Vault
    if grep -q -w SSL "$config_file"; then 
        encrypt_type="SSL"   
    else
        encrypt_type="PFE"
    fi
    echo "Vault Encryption Used: $encrypt_type"

    # Set Vault Variables
    if [[ $vault_name == "vmgr" ]]; then
        filename=$(get_filename_from_config "$config_file" "vaultmgr_name")
        # config_json="vaultmgr_config.json"
    elif [[ $vault_name == "gmgr" ]]; then
        filename=$(get_filename_from_config "$config_file" "gitmgr_name")
        # config_json="gitmgr_config.json"
    fi

    # Initialize Vault Names
    vault_dir="$filename"
    vault_enc="$vault_dir.enc"

    # Load Hash_CFG
    secret_type="Hash_CFG"
    account="$USER"

    # Lookup Secret in Keychain
    if ! secret=$(security find-generic-password -w -s "$secret_type" -a "$account"); then
        echo "Secret Not Found, error $?"
        continue
    fi

    # Set File Hash
    hash_cfg=$(echo "$secret" | base64 --decode)

    # Handle iCloud operations
    icloud_dir="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
    icloud_enc="$icloud_dir/$vault_enc"
    if [[ $action == "dec" || $action == "view" ]] && [[ -f $icloud_enc ]]; then
        if [[ $action == "dec" ]]; then
            mv -i "$icloud_enc" "$HOME/Desktop"
        else
            cp -i "$icloud_enc" "$HOME/Desktop"
        fi
    fi

    # Check For Vault Directory or Encrypted File On Desktop
    if [[ $action == "enc" || $action == "sync" ]] && [[ ! -d $vault_dir ]]; then
        echo "Vault Directory missing on Desktop: $vault_dir"
        echo " "
        read -k 1
        continue
    elif [[ $action == "dec" || $action == "view" ]] && [[ ! -f $vault_enc ]]; then
        echo "Encrypted Vault missing on Desktop: $vault_enc"
        echo " "
        read -k 1
        continue
    fi

    # Perform the selected action
    case $action in
        enc)
            if [[ $encrypt_type == "SSL" ]]; then
                # SSL Encrypt
                tar -cf "$vault_dir.tar" "$vault_dir" && 
                gzip "$vault_dir.tar" && 
                openssl enc -base64 -e -aes-256-cbc -salt -pass pass:"$hash_cfg" -pbkdf2 -iter 1000000 -in "$vault_dir.tar.gz" -out "$vault_enc" && 
                rm -f "$vault_dir.tar.gz"
            else
                # PFE Encrypt
                java -Xmx1g -jar /Applications/Utilities/SSE/ssefenc.jar "$vault_dir" "$hash_cfg" twofish
            fi
            mv -f "$vault_enc" "$icloud_dir"
            rm -rf ~/.trash/"$vault_dir"
            mv -f "$vault_dir" ~/.trash
            echo "Vault Encrypted: $vault_dir"
            echo "Note: Encrypted Vault Moved To iCloud, Encrypted Directory Moved To Trash"
            ;;
        dec|view)
            if [[ $encrypt_type == "SSL" ]]; then
                # SSL Decrypt
                openssl enc -base64 -d -aes-256-cbc -salt -pass pass:"$hash_cfg" -pbkdf2 -iter 1000000 -in "$vault_enc" -out "$vault_dir.tar.gz" && 
                tar -xzf "$vault_dir.tar.gz" && 
                rm -f "$vault_dir.tar.gz"
            else
                # PFE Decrypt
                java -Xmx1g -jar /Applications/Utilities/SSE/ssefenc.jar "$vault_enc" "$hash_cfg"
            fi
            rm -rf ~/.trash/"$vault_enc"
            mv -f "$vault_enc" ~/.trash
            echo "Vault Decrypted: $vault_dir"
            echo "Note: Encrypted Vault Moved To Trash"
            if [[ $action == "view" ]]; then
                echo "When Done Viewing, Move $vault_dir Vault To Trash!"
                open "$HOME/Desktop/$vault_dir"
            fi
            ;;
        sync)
            clear
            echo "GitHUB Sync Starting"
            current_date=$(date)
            echo "$current_date"
            rsync -avh "$HOME/Documents/GitHub/Code-Snippets/" "$HOME/Desktop/GciSttH6UsbSj7I/GitHub/Code-Snippets" --delete
            echo "GitHUB Sync Completed"
            ;;
        back)
            clear
            echo "Backing up $vault_dir"
            echo " "
            if diskutil list external | grep -q 'Private'; then
                echo "Backing up to Private..."
                cp "$icloud_enc" "/Volumes/Private"
                cp "$config_file" "/Volumes/Private/Shortcuts Config Files"
            fi
            echo "Backing up to Downloads..."
            cp "$icloud_enc" "$HOME/Downloads/zVault Backup"
            cp "$config_file" "$HOME/Downloads/zVault Backup/Shortcuts Config Files"
            echo "Vault Backup Completed"
            ;;
    esac

    # Pause before next iteration
    echo " "
    echo "Press any key to continue..."
    read -k 1
done

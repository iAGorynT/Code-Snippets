#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library $FORMAT_LIBRARY not found" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Validate required commands exist
validate_commands() {
    local missing_commands=()
    
    for cmd in tar gzip openssl security base64; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        error_printf "Missing required commands: ${missing_commands[*]}" true
    fi
}

# SSL Encrypt function
ssl_encrypt() {
    local vault_dir="$1"
    local vault_enc="$2"
    local hash_cfg="$3"
    
    tar -cf "$vault_dir.tar" "$vault_dir" || { error_printf "Failed to create tar archive" true; }
    gzip "$vault_dir.tar" || { error_printf "Failed to gzip archive" true; }
    openssl enc -base64 -e -aes-256-cbc -salt -pass pass:"$hash_cfg" -pbkdf2 -iter 1000000 -in "$vault_dir.tar.gz" -out "$vault_enc" || { error_printf "OpenSSL encryption failed" true; }
    rm -f "$vault_dir.tar.gz" || { error_printf "Failed to clean up temporary tar.gz file" true; }
}

# SSL Decrypt function
ssl_decrypt() {
    local vault_dir="$1"
    local vault_enc="$2"
    local hash_cfg="$3"
    
    openssl enc -base64 -d -aes-256-cbc -salt -pass pass:"$hash_cfg" -pbkdf2 -iter 1000000 -in "$vault_enc" -out "$vault_dir.tar.gz" || { error_printf "OpenSSL decryption failed" true; }
    tar -xzf "$vault_dir.tar.gz" || { error_printf "Failed to extract tar archive" true; }
    rm -f "$vault_dir.tar.gz" || { error_printf "Failed to clean up temporary tar.gz file" true; }
}

# PFE Encrypt function
pfe_encrypt() {
    local vault_dir="$1"
    local hash_cfg="$2"
    
    if ! command -v java >/dev/null 2>&1; then
        error_printf "Java is required for PFE encryption but not found" true
    fi
    if [[ ! -f /Applications/Utilities/SSE/ssefenc.jar ]]; then
        error_printf "PFE encryption jar file not found: /Applications/Utilities/SSE/ssefenc.jar" true
    fi
    
    java -Xmx1g -jar /Applications/Utilities/SSE/ssefenc.jar "$vault_dir" "$hash_cfg" twofish || { error_printf "PFE encryption failed" true; }
}

# PFE Decrypt function
pfe_decrypt() {
    local vault_enc="$1"
    local hash_cfg="$2"
    
    if ! command -v java >/dev/null 2>&1; then
        error_printf "Java is required for PFE decryption but not found" true
    fi
    if [[ ! -f /Applications/Utilities/SSE/ssefenc.jar ]]; then
        error_printf "PFE decryption jar file not found: /Applications/Utilities/SSE/ssefenc.jar" true
    fi
    
    java -Xmx1g -jar /Applications/Utilities/SSE/ssefenc.jar "$vault_enc" "$hash_cfg" || { error_printf "PFE decryption failed" true; }
}

# Save passed Vault Type if supplied
# Note: Parameter value should be "vmgr", "gmgr", or left blank
#vaultpassed=$1
vaultpassed=${1:-}

# Validate required commands on startup
validate_commands

# Function to clear screen and display header
display_header() {
    clear
    info_printf "OpenSSL Vault Encrypt / Decrypt"
}

# Function to get filename from JSON config with improved error handling and flexibility
get_filename_from_config() {
    # Check if correct number of arguments is provided
    if [[ $# -ne 2 ]]; then
        error_printf "Usage: get_filename_from_config <config_file> <key>" true
    fi

    local config_file="$1"
    local key="$2"

    # Check if config file exists
    if [[ ! -f "$config_file" ]]; then
        error_printf "Config file '$config_file' not found" true
    fi

    # Prefer jq if available (faster and more robust)
    if command -v jq >/dev/null 2>&1; then
        # Use jq to extract the value, handling potential errors
        local filename
        filename=$(jq -e -r ".$key // empty" "$config_file")
        
        # Check if jq extraction was successful
        if [[ -z "$filename" ]]; then
            error_printf "Unable to find key '$key' in config file" true
        fi
        
        # Using printf to return filename without newline
        printf "%s" "$filename"
        return 0
    fi

    # Fallback method using grep and sed if jq is not available
    local filename
    filename=$(grep -o "\"$key\": *\"[^\"]*\"" "$config_file" | sed -n "s/.*: *\"\(.*\)\"/\1/p")
    
    if [[ -z "$filename" ]]; then
        error_printf "Unable to find key '$key' in config file using fallback method" true
    fi

    printf "%s" "$filename"
}

# Main loop
while true; do
    display_header

    # Set Default Directory To Desktop
    cd "$HOME/Desktop"

    # Define common actions
    common_actions=("Decrypt")
    
    # Add "GitSync" for non-vmgr case
    if [[ $vaultpassed != "vmgr" ]]; then
        common_actions+=("GitSync")
    fi

    # Add remaining common actions
    common_actions+=("Encrypt" "View" "Backup" "Config" "Reset" "Quit")

    printf "\n"
    info_printf "Select Action..." 
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
    printf "\n"

    # Perform the selected action
    case $action in
        quit)
            # Check if user wants to quit
            if [[ $action == "quit" ]]; then
                # Stop Terminal App Launcher
                if osascript -e 'application "Terminal" is running' >/dev/null 2>&1; then
                    info_printf "Stopping Terminal App Launcher"
                    osascript -e 'tell application "Terminal" to quit without saving' >/dev/null 2>&1
                fi
                info_printf "OpenSSL Vault Enc/Dec Completed"
                exit 0
            fi
            ;;
        rset)
            # Reset settings to All Vaults
            vaultpassed=''
            printf '\033[1;34m%s%s%b' "ℹ️ " "Settings reset to All Vaults..." "\033[0m"
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
            info_printf "Standby... ConfigFILES Running"
            shortcuts run "ConfigFILES"
            info_printf "ConfigFILES Complete..."
            continue
            ;;
    esac

    # Select Vault Type
    if [ -z "$vaultpassed" ]; then
        info_printf "Select Vault Type..." 
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
	printf "\n"
    else
        vault_name=$vaultpassed
    fi 

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
    info_printf "Vault Encryption Used: $encrypt_type"

    # Set Vault Variables
    if [[ $vault_name == "vmgr" ]]; then
        filename=$(get_filename_from_config "$config_file" "vaultmgr_name")
    elif [[ $vault_name == "gmgr" ]]; then
        filename=$(get_filename_from_config "$config_file" "gitmgr_name")
    fi

    # Initialize Vault Names
    vault_dir="$filename"
    vault_enc="$vault_dir.enc"

    # Load Hash_CFG
    secret_type="Hash_CFG"
    account="$USER"

    # Lookup Secret in Keychain
    if ! secret=$(security find-generic-password -w -s "$secret_type" -a "$account"); then
        error_printf "Secret Not Found, error $?" true
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
        error_printf "Vault Directory missing on Desktop: $vault_dir"
        read -k 1
        continue
    elif [[ $action == "dec" || $action == "view" ]] && [[ ! -f $vault_enc ]]; then
        error_printf "Encrypted Vault missing on Desktop: $vault_enc"
        read -k 1
        continue
    fi

    # Perform the selected action
    case $action in
        enc)
            if [[ $encrypt_type == "SSL" ]]; then
                # SSL Encrypt
                ssl_encrypt "$vault_dir" "$vault_enc" "$hash_cfg"
            else
                # PFE Encrypt
                pfe_encrypt "$vault_dir" "$hash_cfg"
            fi
            mv -f "$vault_enc" "$icloud_dir" || { error_printf "Failed to move encrypted vault to iCloud" true; }
            rm -rf ~/.trash/"$vault_dir"
            mv -f "$vault_dir" ~/.trash || { error_printf "Failed to move vault directory to trash" true; }
            info_printf "Vault Encrypted: $vault_dir"
            info_printf "Note: Encrypted Vault Moved To iCloud, Encrypted Directory Moved To Trash"
            ;;
        dec|view)
            if [[ $encrypt_type == "SSL" ]]; then
                # SSL Decrypt
                ssl_decrypt "$vault_dir" "$vault_enc" "$hash_cfg"
            else
                # PFE Decrypt
                pfe_decrypt "$vault_enc" "$hash_cfg"
            fi
            rm -rf ~/.trash/"$vault_enc"
            mv -f "$vault_enc" ~/.trash || { error_printf "Failed to move encrypted vault to trash" true; }
            info_printf "Vault Decrypted: $vault_dir"
            info_printf "Note: Encrypted Vault Moved To Trash"
            if [[ $action == "view" ]]; then
                warning_printf "When Done Viewing, Move $vault_dir Vault To Trash!"
                open "$HOME/Desktop/$vault_dir" || { error_printf "Failed to open vault directory" true; }
            fi
            ;;
        sync)
            clear
            info_printf "GitHUB Sync Starting"
            current_date=$(date)
            time_printf "$current_date"
            rsync -avh "$HOME/Documents/GitHub/Code-Snippets/" "$HOME/Desktop/GciSttH6UsbSj7I/GitHub/Code-Snippets" --delete --exclude '.DS_Store'
            info_printf "GitHUB Sync Completed"
            ;;
        back)
            clear
            info_printf "Backing up $vault_dir" 
            if diskutil list external | grep -q 'Private'; then
                info_printf "Backing up to Private..."
                cp "$icloud_enc" "/Volumes/Private"
                cp "$config_file" "/Volumes/Private/Shortcuts Config Files"
            fi
            info_printf "Backing up to Downloads..."
            cp "$icloud_enc" "$HOME/Downloads/zVault Backup"
            cp "$config_file" "$HOME/Downloads/zVault Backup/Shortcuts Config Files"
            info_printf "Vault Backup Completed"
            ;;
    esac

    # Pause before next iteration
    printf "\n"
    printf "Press any key to continue"
    read -k 1
done

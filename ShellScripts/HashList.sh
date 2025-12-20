#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Define temporary files using mktemp for secure creation
TEMP_FILE=$(mktemp)
ENCRYPTED_FILE=$(mktemp)

# Array of app names
hash_keys=("Hash_CFG" "Hash2_CFG" "Hash3_CFG" "Hash4_CFG" "OTPGenerator")

# Function to securely cleanup files
cleanup() {
    rm -f "$TEMP_FILE" "$ENCRYPTED_FILE"
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Function to display menu and handle user selection
show_menu() {
    local encrypted_file="$1"
    local temp_file="$2"
    
    while true; do
        clear
        format_printf "Hash Key Report - Clipboard Menu" "yellow" "bold"
        printf "\n"
        printf "Select an option to copy to clipboard:\n\n"
        printf "1) Copy decryption command (direct print)\n"
        printf "2) Copy decryption command (to file)\n"
        printf "3) Copy decryption command (view on screen)\n"
        printf "4) Exit\n\n"
        
        printf "Enter your choice (1-4): "
        read -r choice
        
        case "$choice" in
            1)
                local cmd1="openssl enc -aes-256-cbc -pbkdf2 -d -in $encrypted_file | lp"
                echo -n "$cmd1" | pbcopy
                format_printf "✓ Option 1 copied to clipboard" "green" "bold"
                printf "\n"
                read -k "?Press any key to continue..."
                ;;
            2)
                local cmd2="openssl enc -aes-256-cbc -pbkdf2 -d -in $encrypted_file > ~/Desktop/hash_report_temp.txt"
                echo -n "$cmd2" | pbcopy
                format_printf "✓ Option 2 copied to clipboard" "green" "bold"
                printf "\n"
                read -k "?Press any key to continue..."
                ;;
            3)
                local cmd3="openssl enc -aes-256-cbc -pbkdf2 -d -in $encrypted_file"
                echo -n "$cmd3" | pbcopy
                format_printf "✓ Option 3 copied to clipboard" "green" "bold"
                printf "\n"
                read -k "?Press any key to continue..."
                ;;
            4)
                format_printf "Exiting..." "cyan"
                printf "\n"
                return 0
                ;;
            *)
                format_printf "Invalid choice. Please enter 1-4." "red" "bold"
                printf "\n"
                read -k "?Press any key to continue..."
                ;;
        esac
    done
}

# Function to lookup Enigma Hash Keys
lookup_hash_keys() {
    clear
    format_printf "Generating Hash Key Report..." "yellow" "bold"
    
    # Create temporary plaintext file with header
    {
        printf "Hash Key Report\n"
        printf "Generated: %s\n" "$(date '+%Y-%m-%d %H:%M:%S')"
        printf "=%.0s" {1..80}
        printf "\n\n"
    } > "$TEMP_FILE"
    
    local error_count=0
    local success_count=0
    
    for hash_key in "${hash_keys[@]}"; do
    
        # Use the hash_key from array as secret_type
        secret_type="$hash_key"
        # Set account based username
        account="$USER"
    
        # Lookup Secret in Keychain (suppress stderr)
        if ! secret=$(security find-generic-password -w -s "$secret_type" -a "$account" 2>/dev/null); then
            # Write error to file only (no console output)
            {
                printf "Hash Key: %s\n" "$hash_key"
                printf "Status: ERROR - Not Found in Keychain\n"
                printf "\n"
            } >> "$TEMP_FILE"
            ((error_count++))
            continue
        fi
    
        # Write to output file (keep base64 encoded, no decoding)
        {
            printf "Hash Key: %s\n" "$hash_key"
            printf "Hash Key Value (base64): %s\n" "$secret"
            printf "\n"
        } >> "$TEMP_FILE"
        ((success_count++))

    done
    
    # Encrypt the file using openssl with PBKDF2 (modern, non-deprecated)
    printf "\n"
    format_printf "Enter passphrase to encrypt report:" "cyan"
    printf "\n"
    
    if openssl enc -aes-256-cbc -pbkdf2 -salt -in "$TEMP_FILE" -out "$ENCRYPTED_FILE"; then
        format_printf "✓ Report encrypted successfully" "green" "bold"
        printf "\n"
        printf "Encrypted file: %s\n" "$ENCRYPTED_FILE"
        printf "Recovered keys: %d\n" "$success_count"
        printf "Missing keys: %d\n" "$error_count"
        printf "\n"
        format_printf "CLIPBOARD MENU:" "yellow" "bold"
        printf "\n"
        printf "You can now copy decryption commands to your clipboard.\n"
        printf "\n"
        read -k "?Press any key to continue to menu..."
        printf "\n"
        
        # Show the menu
        show_menu "$ENCRYPTED_FILE" "$TEMP_FILE"
        
        format_printf "NOTE:" "red" "bold"
        printf "The encrypted file will now be deleted.\n"
        printf "If you created a plaintext file, remember to delete it manually.\n"
        printf "\n"
    else
        format_printf "✗ Encryption failed" "red" "bold"
        printf "\n"
        return 1
    fi
}

# Call the function
lookup_hash_keys

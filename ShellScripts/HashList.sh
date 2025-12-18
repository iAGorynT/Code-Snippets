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
        
        # Set account based on hash_key prefix
        if [[ "$hash_key" == Hash* ]]; then
            account="$USER"
        else
            account="MasterPassword"
        fi
    
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
        format_printf "INSTRUCTIONS FOR PRINTING:" "yellow" "bold"
        printf "\n"
        printf "Option 1 - Decrypt and print directly:\n"
        printf "  openssl enc -aes-256-cbc -pbkdf2 -d -in %s | lp\n" "$ENCRYPTED_FILE"
        printf "\n"
        printf "Option 2 - Decrypt to temporary file for review, then print:\n"
        printf "  openssl enc -aes-256-cbc -pbkdf2 -d -in %s > ~/Desktop/hash_report_temp.txt\n" "$ENCRYPTED_FILE"
        printf "  Then print from ~/Desktop/hash_report_temp.txt and delete it when done\n"
        printf "\n"
        printf "Option 3 - View on screen first:\n"
        printf "  openssl enc -aes-256-cbc -pbkdf2 -d -in %s\n" "$ENCRYPTED_FILE"
        printf "\n"
        format_printf "NOTE:" "red" "bold"
        printf "Press ANY KEY when you are finished using the encrypted file above.\n"
        printf "The encrypted file will be deleted after you confirm.\n"
        printf "If you created a plaintext file (Option 2), remember to delete it manually.\n"
        printf "\n"
        
        # Wait for user confirmation before cleanup
        read -k "?Press any key to exit"
    else
        format_printf "✗ Encryption failed" "red" "bold"
        printf "\n"
        return 1
    fi
}

# Call the function
lookup_hash_keys

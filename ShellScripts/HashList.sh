#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Define output file
OUTPUT_FILE="$HOME/Downloads/zVault Backup/Enigma/hash_keys_output.txt"

# List Selected Application Descriptions
clear
format_printf "Hash Listing..." "yellow" "bold"
printf "\n"

# Array of app names
hash_keys=("Hash_CFG" "Hash2_CFG" "Hash3_CFG" "Hash4_CFG" "OTPGenerator")

# Function to lookup Enigma Hash Keys
lookup_hash_keys() {
    # Clear/create output file with header
    {
        printf "Hash Key Report\n"
        printf "Generated: %s\n" "$(date '+%Y-%m-%d %H:%M:%S')"
        printf "=%.0s" {1..80}
        printf "\n\n"
    } > "$OUTPUT_FILE"
    
    for hash_key in "${hash_keys[@]}"; do
    
        # Use the hash_key from array as secret_type
        secret_type="$hash_key"
        
        # Set account based on hash_key prefix
        if [[ "$hash_key" == Hash* ]]; then
            account="$USER"
        else
            account="MasterPassword"
        fi
    
        # Lookup Secret in Keychain
        if ! secret=$(security find-generic-password -w -s "$secret_type" -a "$account" 2>&1); then
            # Print error to console without exiting
            printf "\033[1;31m✗ Secret Not Found for %s\033[0m\n" "$hash_key"
            # Write error to file
            {
                printf "Hash Key: %s\n" "$hash_key"
                printf "Status: ERROR - Not Found in Keychain\n"
                printf "\n"
            } >> "$OUTPUT_FILE"
            continue
        fi
    
        # Decode the base64 value
        hash_cfg=$(echo "$secret" | base64 --decode)

        # Print to console
        printf "\033[1;32m%s:\033[0m %s\n" "$hash_key" "$secret"
        
        # Write to output file
        {
            printf "Hash Key: %s\n" "$hash_key"
            printf "Hash Key Value (base64): %s\n" "$secret"
            printf "Decoded Value: %s\n" "$hash_cfg"
            printf "\n"
        } >> "$OUTPUT_FILE"

    done
    
    # Print completion message
    printf "\033[1;36mOutput written to: %s\033[0m\n" "$OUTPUT_FILE"

    bat $OUTPUT_FILE
}

# Call the function
lookup_hash_keys

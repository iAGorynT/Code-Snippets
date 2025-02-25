#!/bin/zsh

# Set secure file locations
ENCRYPTED_FILE="$HOME/.config/gauth.csv"
DECRYPTED_FILE="$(mktemp)"

# Automatically clean up temporary file on exit
trap 'rm -f "$DECRYPTED_FILE"' EXIT INT TERM HUP

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

# Function for decryption of gauth.csv
decrypt_file() {
    if ! openssl enc -d -aes-128-cbc -md sha256 \
         -in "$ENCRYPTED_FILE" -out "$DECRYPTED_FILE" -pass pass:"$GAUTH_PASSWORD" 2>/dev/null; then
        error_print "Error: Decryption failed." true
        return 1
    fi
    
    if [[ ! -s "$DECRYPTED_FILE" ]]; then
        error_print "Error: Decrypted file is empty." true
        return 1
    fi
    
    return 0
}

displayhdr() {
    clear
    format_printf "Gauth Authenticator..." "yellow" "bold"
    printf "\n"
}

# Function to get authentication code
get_auth_code() {
    displayhdr
    Gauth.exp  # Assuming this gets the actual authentication code
}

# Main function
main() {
    displayhdr

    # Check if encrypted file exists
    if [[ ! -f "$ENCRYPTED_FILE" ]]; then
        error_print "Error: Encrypted file not found at $ENCRYPTED_FILE" true
        return 1
    fi

    # Load Hash_CFG
    local secret_type="Hash2_CFG"
    local account="$USER"

    # Lookup Secret in Keychain
    local secret
    if ! secret=$(security find-generic-password -w -s "$secret_type" -a "$account"); then
        error_print "Secret Not Found, error $?" true
        return 1
    fi

    # Set File Hash and Temporary Environment variable
    local hash_cfg=$(echo "$secret" | base64 --decode)
    export GAUTH_PASSWORD="$hash_cfg"
    
    # Attempt decryption
    if ! decrypt_file; then
        return 1
    fi
    
    # Extract key names more efficiently
    local keys=()
    while IFS=: read -r key _; do
        [[ -n "$key" ]] && keys+=("$key")
    done < "$DECRYPTED_FILE"
    
    # Check if keys exist
    if (( ${#keys[@]} == 0 )); then
        error_print "No records found in the file." true
        return 1
    fi
    
    # Present menu only if there's more than one key
    if (( ${#keys[@]} == 1 )); then
        export GAUTH_KEY="${keys[1]}"
        format_printf "Using the only available key: $GAUTH_KEY"
        printf "\n"
    else
        # User selection menu with numbered options
        info_printf "Select a record to process:"
        printf "\n"
        select key in "${keys[@]}"; do
            if [[ -n "$key" ]]; then
                format_printf "You selected: $key"
                export GAUTH_KEY="$key"
                printf "\n"
                break
            else
                echo "Invalid selection. Try again."
            fi
        done
    fi

    return 0
}

# Call the main function once
if ! main; then
    exit 1
fi

# Main loop for refreshing auth codes
while true; do
    get_auth_code
    
    printf "\nRefresh Auth Codes? (y/n): "
    read -rk1 response
    echo # Add newline after response
    
    case ${(L)response} in  # More efficient lowercase conversion
        y) displayhdr; continue ;;
        *) break ;;
    esac
done

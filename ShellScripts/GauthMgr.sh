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
        error_printf "Error: Decryption failed." true
        return 1
    fi
    
    if [[ ! -s "$DECRYPTED_FILE" ]]; then
        error_printf "Error: Decrypted file is empty." true
        return 1
    fi
    
    return 0
}

# Function to encrypt the modified file
encrypt_file() {
    if ! openssl enc -e -aes-128-cbc -md sha256 \
         -in "$DECRYPTED_FILE" -out "$ENCRYPTED_FILE" -pass pass:"$GAUTH_PASSWORD" 2>/dev/null; then
        error_printf "Error: Encryption failed." true
        return 1
    fi
    
    return 0
}

# Display header function
display_header() {
    clear
    format_printf "Gauth Manager..." "yellow" "bold"
    printf "\n"
}

# Function to get a new key name from the user
get_new_key_name() {
    local key_name=""
    while [[ -z "$key_name" ]]; do
        printf "Enter name for new key: "
        read -r key_name
        
        if [[ -z "$key_name" ]]; then
            error_printf "Key name cannot be empty. Please try again."
        fi
        
        # Check if key already exists
        if grep -q "^$key_name:" "$DECRYPTED_FILE" 2>/dev/null; then
            error_printf "A key with this name already exists. Please choose another name."
            key_name=""
        fi
    done
    
    export GAUTH_KEY="$key_name"
    format_printf "New key name set: $GAUTH_KEY" "green"
    printf "\n"
    return 0
}

# Function to perform maintenance processing based on operation
process_operation() {
    local operation=$1
    
    display_header
    
    case "$operation" in
        "add")
            info_printf "Adding key: $GAUTH_KEY..."
            export GAUTH_ACTION="-a"
            GauthMgr.exp  # Gauth Key addition
            printf "\n"
            ;;
        "remove")
            info_printf "Removing key: $GAUTH_KEY..."
            export GAUTH_ACTION="-r"
            GauthMgr.exp  # Gauth Key removal
            ;;
        "dump")
            info_printf "Displaying contents of GAUTH keys file:"
            printf "\n\n"
            cat "$DECRYPTED_FILE"
            printf "\n"
            read -r "?Press Enter to continue..."
            ;;
        *)
            error_printf "Unknown operation: $operation" true
            return 1
            ;;
    esac
    
    return 0
}

# Function to select operation
select_operation() {
    display_header
    info_printf "Select an operation:"
    printf "\n"
    
    local operations=("Add" "Remove" "Dump" "Exit")
    select op in "${operations[@]}"; do
        case $REPLY in
            1)
                return_operation="add"
                break
                ;;
            2)
                return_operation="remove"
                break
                ;;
            3)
                return_operation="dump"
                break
                ;;
            4)
                return_operation="exit"
                break
                ;;
            *)
                echo "Invalid selection. Please try again."
                ;;
        esac
    done
    
    return 0
}

# Function to select a key
select_key() {
    # Extract key names efficiently
    local keys=()
    while IFS=: read -r key _; do
        [[ -n "$key" ]] && keys+=("$key")
    done < "$DECRYPTED_FILE"
    
    # Check if keys exist
    if (( ${#keys[@]} == 0 )); then
        error_printf "No records found in the file." true
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

# Main function
main() {
    # Check if encrypted file exists - create an empty one if it doesn't exist and it's an add operation
    if [[ ! -f "$ENCRYPTED_FILE" ]]; then
        info_printf "Note: Encrypted file not found at $ENCRYPTED_FILE" 
        info_printf "An empty encrypted file will be created if adding a new key."
    fi

    # Load Hash_CFG
    local secret_type="Hash2_CFG"
    local account="$USER"

    # Lookup Secret in Keychain
    local secret
    if ! secret=$(security find-generic-password -w -s "$secret_type" -a "$account"); then
        error_printf "Secret Not Found, error $?" true
        return 1
    fi

    # Set File Hash and Temporary Environment variable
    local hash_cfg=$(echo "$secret" | base64 --decode)
    export GAUTH_PASSWORD="$hash_cfg"
    
    # Attempt decryption if file exists
    if [[ -f "$ENCRYPTED_FILE" ]]; then
        if ! decrypt_file; then
            # If decryption fails but we're adding a new key, we can create an empty file
            if [[ "$operation" == "add" ]]; then
                touch "$DECRYPTED_FILE"
            else
                return 1
            fi
        fi
    else
        # Create empty decrypted file for add operation
        touch "$DECRYPTED_FILE"
    fi
    
    # Select operation
    local operation=""
    select_operation
    operation=$return_operation
    
    # Exit if user selected exit
    if [[ "$operation" == "exit" ]]; then
        return 2
    fi
    
    # For add operation, prompt for new key name
    if [[ "$operation" == "add" ]]; then
        if ! get_new_key_name; then
            return 1
        fi
    # For remove operation or other operations that need a key selection
    elif [[ "$operation" != "dump" ]]; then
        if ! select_key; then
            return 1
        fi
    fi
    
    # Process the selected operation
    if ! process_operation "$operation"; then
        return 1
    fi
    
    return 0
}

# Main processing loop
while true; do
    main_result=0
    main || main_result=$?
    
    # Exit if user requested (code 2)
    if [[ $main_result -eq 2 ]]; then
        break
    fi
    
    # Continue or exit
    printf "\nContinue Gauth Manager? (y/n): "
    read -rk1 response
    printf "\n" # Add newline after response
    
    case ${(L)response} in  # Lowercase conversion
        y) continue ;;
        *) break ;;
    esac
done

# Final message
printf "\n"
success_printf "Exiting Gauth Manager..."
exit 0

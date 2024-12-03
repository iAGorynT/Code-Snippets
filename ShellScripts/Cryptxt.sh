#!/bin/zsh

# OpenSSL Text Encrypt / Decrypt Script
# Provides secure encryption and decryption using OpenSSL

# Function to display usage information
usage() {
    echo "Usage: $0 [enc|dec]"
    echo "Encrypts or decrypts text using OpenSSL AES-256-CBC encryption"
    echo 
    echo "Options:"
    echo "  enc   Encrypt text"
    echo "  dec   Decrypt text"
    exit 1
}

# Function to handle encryption
encrypt_text() {
    local text="$1"
    local password="$2"
    
    if [[ -z "$text" || -z "$password" ]]; then
        echo "Error: Text and password are required for encryption." >&2
        exit 1
    fi
    
    echo
    echo "ENCODE:"
    echo -n "$text" | openssl enc -base64 -e -aes-256-cbc -salt \
        -pass pass:"$password" -pbkdf2 -iter 1000000 | tr -d '\n' | tee >(pbcopy)
    echo -e "\nEncrypted text has been copied to clipboard."
}

# Function to handle decryption
decrypt_text() {
    local encrypted_text="$1"
    local password="$2"
    
    if [[ -z "$encrypted_text" || -z "$password" ]]; then
        echo "Error: Encrypted text and password are required for decryption." >&2
        exit 1
    fi
    
    echo
    echo "DECODE:"
    echo "$encrypted_text" | openssl enc -base64 -d -aes-256-cbc -salt \
        -pass pass:"$password" -pbkdf2 -iter 1000000
}

# Main script execution
main() {
    # Clear screen and display header
    clear
    echo "OpenSSL Text Encrypt / Decrypt"
    echo 

    # Check if action is provided as argument, otherwise prompt
    local action="${1:-}"
    if [[ -z "$action" ]]; then
        while true; do
            echo -n "Choose action (enc/dec): "
            read action
            [[ "$action" =~ ^(enc|dec)$ ]] && break
            echo "Invalid option. Please enter 'enc' or 'dec'."
        done
    elif [[ ! "$action" =~ ^(enc|dec)$ ]]; then
        usage
    fi

    # Prompt for input text
    echo -n "Enter text to $([[ "$action" == "enc" ]] && echo "encrypt" || echo "decrypt"): "
    read input_text

    # Prompt for password securely
    echo -n "Enter password: "
    read -s password
    echo  # Add newline after password input

    # Perform encryption or decryption
    if [[ "$action" == "enc" ]]; then
        encrypt_text "$input_text" "$password"
    else
        decrypt_text "$input_text" "$password"
    fi

    echo  # Final newline for clean output
}

# Run the main function with command-line arguments
main "$@"

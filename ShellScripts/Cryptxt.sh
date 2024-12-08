#!/bin/zsh
# OpenSSL Text Encrypt / Decrypt Script
# Provides secure encryption and decryption using OpenSSL

# Function for centralized info and error reporting
info_error_report() {
    local type="$1"
    local message="$2"
    local stop_execution="${3:-false}"
    
    # Determine output stream and color based on type
    if [[ "$type" == "Error" ]]; then
        echo -e "\e[31m[ERROR]\e[0m $message" >&2
    elif [[ "$type" == "Info" ]]; then
        echo -e "\e[32m[INFO]\e[0m $message"
    else
        echo -e "\e[33m[WARNING]\e[0m $message"
    fi
    
    # Optional script termination
    if [[ "$stop_execution" == "true" ]]; then
        exit 1
    fi
}

# Function to display usage information
usage() {
    info_error_report "Info" "Usage: $0 [enc|dec]"
    info_error_report "Info" "Encrypts or decrypts text using OpenSSL AES-256-CBC encryption"
    info_error_report "Info" "\nOptions:"
    info_error_report "Info" "  enc   Encrypt text"
    info_error_report "Info" "  dec   Decrypt text"
    exit 1
}

# Function to handle encryption
encrypt_text() {
    local text="$1"
    local password="$2"
    
    if [[ -z "$text" || -z "$password" ]]; then
        info_error_report "Error" "Text and password are required for encryption." "true"
    fi
    
    info_error_report "Info" "ENCODE:"
    echo -n "$text" | openssl enc -base64 -e -aes-256-cbc -salt \
        -pass pass:"$password" -pbkdf2 -iter 1000000 | tr -d '\n' | tee >(pbcopy)
    echo
    info_error_report "Info" "Encrypted text has been copied to clipboard."
}

# Function to handle decryption
decrypt_text() {
    local encrypted_text="$1"
    local password="$2"
    
    if [[ -z "$encrypted_text" || -z "$password" ]]; then
        info_error_report "Error" "Encrypted text and password are required for decryption." "true"
    fi
    
    info_error_report "Info" "DECODE:"
    echo "$encrypted_text" | openssl enc -base64 -d -aes-256-cbc -salt \
        -pass pass:"$password" -pbkdf2 -iter 1000000
}

# Main script execution
main() {
    # Clear screen and display header
    clear
    info_error_report "Info" "OpenSSL Text Encrypt / Decrypt"
    
    # Check if action is provided as argument, otherwise prompt
    local action="${1:-}"
    if [[ -z "$action" ]]; then
        while true; do
            echo -n "Choose action (enc/dec): "
            read action
            [[ "$action" =~ ^(enc|dec)$ ]] && break
            info_error_report "Error" "Invalid option. Please enter 'enc' or 'dec'."
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

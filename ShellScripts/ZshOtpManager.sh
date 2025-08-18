#!/bin/zsh
# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    printf "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

# Set secure file locations
ENCRYPTED_FILE="$HOME/.otp_secrets_zsh.enc"
DECRYPTED_FILE="$(mktemp)"

# Trap for ensuring cleanup on exit
trap cleanup_and_exit INT TERM EXIT

# Function to print error messages - replaced with library function
error_print() {
    local message="$1"
    local exit_after="${2:-false}"
    
    error_printf "$message"
    
    if [[ "$exit_after" == "true" ]]; then
        cleanup_and_exit
    fi
}

# Function to retrieve password from keychain
get_password() {
    # Load Hash_CFG
    local secret_type="OTPGenerator"
    local account="MasterPassword"
    
    # Lookup Secret in Keychain
    local secret
    if ! secret=$(security find-generic-password -w -s "$secret_type" -a "$account" 2>/dev/null); then
        error_print "Secret Not Found, error $?" true
        return 1
    fi
    
    # Set File Hash and Temporary Environment variable
    GAUTH_PASSWORD=$(printf "%s" "$secret" | base64 --decode)
    
    if [[ -z "$GAUTH_PASSWORD" ]]; then
        error_print "Failed to decode password" true
        return 1
    fi
    return 0
}

# Function for decryption of otp secrets file
decrypt_file() {
    if [[ ! -f "$ENCRYPTED_FILE" ]]; then
        error_print "Error: Encrypted file doesn't exist at $ENCRYPTED_FILE" true
        return 1
    fi
    
    if ! openssl enc -d -aes-256-cbc -salt -pass pass:"$GAUTH_PASSWORD" -pbkdf2 -iter 1000000 -in "$ENCRYPTED_FILE" -out "$DECRYPTED_FILE" 2>/dev/null; then
        error_print "Error: Decryption failed." true
        return 1
    fi
    
    # Set secure permissions on decrypted file
    chmod 600 "$DECRYPTED_FILE"
    
    return 0
}

# Function for encryption of otp secrets file
encrypt_file() {
    if ! openssl enc -aes-256-cbc -salt -pass pass:"$GAUTH_PASSWORD" -pbkdf2 -iter 1000000 -in "$DECRYPTED_FILE" -out "$ENCRYPTED_FILE" 2>/dev/null; then
        error_print "Error: Re-encryption failed!" true
        return 1
    fi
    
    success_printf "File successfully re-encrypted."
    return 0
}

# Function to cleanup and exit
cleanup_and_exit() {
    # Clean up password variable first
    unset GAUTH_PASSWORD
    
    # Securely remove the decrypted file
    if [[ -f "$DECRYPTED_FILE" ]]; then
        rm -P "$DECRYPTED_FILE" 2>/dev/null || rm "$DECRYPTED_FILE"
    fi
    
    # Only print goodbye message if not already exiting due to error
    if [[ $? -eq 0 ]]; then
        info_printf "Exiting Zsh OTP Manager. Goodbye!"
    fi
    
    # Remove the trap before exiting to prevent recursive calls
    trap - INT TERM EXIT
    exit $?
}

# Function to wait for MacVim to open file and then close
wait_for_macvim_with_file() {
    local file_path="$1"
    
    # Wait for MacVim application to be running
    info_printf "Waiting for MacVim to start..."
    local attempts=0
    
    # Wait up to 10 seconds for MacVim to start
    while [[ $attempts -lt 10 ]]; do
        if pgrep -f "MacVim" >/dev/null 2>&1; then
            break
        fi
        sleep 1
        ((attempts++))
    done
    
    if [[ $attempts -ge 10 ]]; then
        warning_printf "MacVim may not have started. Continuing anyway..."
        return 1
    fi
    
    info_printf "MacVim started. Waiting for you to close it..."
    
    # Now wait for ALL MacVim processes to close
    # This is more reliable than trying to track specific files
    while pgrep -f "MacVim" >/dev/null 2>&1; do
        sleep 2
    done
    
    info_printf "MacVim closed. Giving it a moment to finish saving..."
    # Give extra time for file system to sync
    sleep 3
}

# Main execution
# Clear the terminal
clear

# Check if MacVim is installed
if ! command -v mvim >/dev/null 2>&1; then
    error_print "Error: MacVim is not installed or not in PATH." true
fi

# Retrieve password from keychain
if ! get_password; then
    error_print "Error: Failed to retrieve password from keychain." true
fi

# Decrypt the file
if ! decrypt_file; then
    error_print "Error: Failed to decrypt file." true
fi

# Open the decrypted file in MacVim and capture the process
format_printf "Opening secret file in MacVim..." "cyan"

# Get the initial modification time
initial_mtime=$(stat -f "%m" "$DECRYPTED_FILE")

# Open MacVim
open -a MacVim "$DECRYPTED_FILE"

# Wait for MacVim to open and then close
warning_printf "Please close MacVim when you're done editing to continue..."
wait_for_macvim_with_file "$DECRYPTED_FILE"

# Check if the file was modified
current_mtime=$(stat -f "%m" "$DECRYPTED_FILE")
if [[ "$current_mtime" != "$initial_mtime" ]]; then
    info_printf "File was modified, proceeding with re-encryption..."
    # Re-encrypt the file
    if ! encrypt_file; then
        error_print "Error: Failed to re-encrypt file." true
    fi
else
    info_printf "File was not modified, skipping re-encryption."
fi

# Cleanup and exit (will be called by trap)
exit 0
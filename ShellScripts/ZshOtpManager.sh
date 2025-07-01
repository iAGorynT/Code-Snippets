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
    # Securely remove the decrypted file
    if [[ -f "$DECRYPTED_FILE" ]]; then
        rm -P "$DECRYPTED_FILE" 2>/dev/null || rm "$DECRYPTED_FILE"
    fi
    
    # Unset the password variable
    unset GAUTH_PASSWORD
    
    # Only print goodbye message if not already exiting due to error
    if [[ $? -eq 0 ]]; then
        info_printf "Exiting Zsh OTP Manager. Goodbye!"
    fi
    
    # Remove the trap before exiting to prevent recursive calls
    trap - INT TERM EXIT
    exit $?
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

# Open the decrypted file in MacVim
format_printf "Opening secret file in MacVim..." "cyan"

open -a MacVim "$DECRYPTED_FILE"

# Wait for MacVim to close the file
warning_printf "Waiting for MacVim to close..."

# Get the initial modification time
initial_mtime=$(stat -f "%m" "$DECRYPTED_FILE")
current_mtime=$initial_mtime

# Wait for the file to be modified and then closed
while pgrep MacVim >/dev/null; do
    # Check if the file has been modified
    current_mtime=$(stat -f "%m" "$DECRYPTED_FILE")
    if [[ "$current_mtime" != "$initial_mtime" ]]; then
        # File has been modified, now wait for MacVim to close
        break
    fi
    sleep 1
done

# If file was modified, wait for MacVim to fully close
if [[ "$current_mtime" != "$initial_mtime" ]]; then
    # Wait for the user to close MacVim
    osascript -e 'tell application "MacVim" to quit'
    # Give it a moment to complete saving
    sleep 1
fi

# Re-encrypt the file
if ! encrypt_file; then
    error_print "Error: Failed to re-encrypt file." true
fi

# Cleanup and exit (will be called by trap)
exit 0

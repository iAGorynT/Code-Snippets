#!/bin/zsh
# Set secure file locations
ENCRYPTED_FILE="$HOME/.otp_secrets_zsh.enc"
DECRYPTED_FILE="$(mktemp)"
# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
# Trap for ensuring cleanup on exit
trap cleanup_and_exit INT TERM EXIT
# Function to print error messages
error_print() {
    local message="$1"
    local exit_after="${2:-false}"
    
    printf "${RED}%s${NC}\n" "$message" >&2
    
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
    
    printf "${GREEN}File successfully re-encrypted.${NC}\n"
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
        printf "\n${BLUE}Exiting Zsh OTP Manager. Goodbye!${NC}\n"
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
printf "${CYAN}Opening secret file in MacVim...${NC}\n"
open -a MacVim "$DECRYPTED_FILE"
# Wait for MacVim to close the file
printf "${YELLOW}Waiting for MacVim to close...${NC}\n"
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

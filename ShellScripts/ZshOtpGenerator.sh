#!/usr/bin/env zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    printf "Error: Required library $FORMAT_LIBRARY not found" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

# Check if pyotp is installed
if ! python3 -c "import pyotp" &> /dev/null; then
    error_printf "Error: pyotp is required but not installed." 
    error_printf "Please install pyotp package:"
    error_printf "  - Using pip: pip install pyotp"
    error_printf "  - Or: python3 -m pip install pyotp"
    exit 1
fi

# Set secure file locations
ENCRYPTED_FILE="$HOME/.otp_secrets_zsh.enc"
DECRYPTED_FILE="$(mktemp)"

if [[ ! -r "$ENCRYPTED_FILE" ]]; then
    error_printf "Error: Cannot read file '$ENCRYPTED_FILE'" 
    exit 1
fi

# TOTP period in seconds (typically 30)
TOTP_PERIOD=30

# Function to retrieve password from keychain
get_password() {
    local secret_type="OTPGenerator"
    local account="MasterPassword"
    local secret
    if ! secret=$(security find-generic-password -w -s "$secret_type" -a "$account"); then
        error_printf "Secret Not Found, error $?"
        return 1
    fi
    GAUTH_PASSWORD=$(echo "$secret" | base64 --decode)
    [[ -z "$GAUTH_PASSWORD" ]] && { error_printf "Failed to decode password"; return 1; }
    return 0
}

# Function for decryption of otp secrets file
decrypt_file() {
    if ! openssl enc -d -aes-256-cbc -salt -pass pass:"$GAUTH_PASSWORD" -pbkdf2 -iter 1000000 -in "$ENCRYPTED_FILE" -out "$DECRYPTED_FILE" 2>/dev/null; then
        error_printf "Error: Decryption failed."
        return 1
    fi
    [[ ! -s "$DECRYPTED_FILE" ]] && { error_printf "Error: Decrypted file is empty."; return 1; }
    return 0
}

# Function to calculate seconds until next TOTP rotation
calculate_seconds_remaining() {
    local current_time=$(date +%s)
    echo $(( TOTP_PERIOD - (current_time % TOTP_PERIOD) ))
}

# Function to generate TOTP code
generate_current_totp() {
    local secret="$1"
    python3 -c "import pyotp; print(pyotp.TOTP('$secret').now())" 2>/dev/null
}

# Function to generate next TOTP code
generate_next_totp() {
    local secret="$1"
    python3 -c "import pyotp, time; print(pyotp.TOTP('$secret').at(int(time.time()) + $TOTP_PERIOD))" 2>/dev/null
}

# Copy to clipboard function
copy_to_clipboard() {
    local text="$1"
    if command -v pbcopy &> /dev/null; then
        echo -n "$text" | pbcopy
    elif command -v xclip &> /dev/null; then
        echo -n "$text" | xclip -selection clipboard
    elif command -v wl-copy &> /dev/null; then
        echo -n "$text" | wl-copy
    elif command -v clip.exe &> /dev/null; then
        echo -n "$text" | clip.exe
    else
        return 1
    fi
    return 0
}

# Display codes once with time remaining
clear_and_display() {
    clear
    local current_date=$(date "+%Y-%m-%d %H:%M:%S")
    local seconds_remaining=$(calculate_seconds_remaining)
    format_printf "TOTP Codes - $current_date" "blue" "bold"
    format_printf "Time left in this OTP period: ${seconds_remaining}s" "cyan" "bold"
    printf "\n"

    printf "\e[1;33m%-4s %-30s %-16s %-16s %s\e[0m\n" "No." "Key Name" "Current TOTP" "Next TOTP" "Actions"
    printf "%-4s %-30s %-16s %-16s %s\n" "----" "$(printf '%0.s-' {1..30})" "$(printf '%0.s-' {1..16})" "$(printf '%0.s-' {1..16})" "-------"

    local counter=1
    while IFS=: read -r name secret || [[ -n "$name" ]]; do
        [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
        name=$(echo "$name" | tr -d '[:space:]')
        secret=$(echo "$secret" | tr -d '[:space:]')
        [[ -z "$secret" ]] && continue

        current_totp=$(generate_current_totp "$secret")
        next_totp=$(generate_next_totp "$secret")
        printf "%-4d %-30s \033[0;32m%-16s\033[0m %-16s [%d:copy]\n" "$counter" "$name" "$current_totp" "$next_totp" "$counter"
        counter=$((counter + 1))
    done < "$DECRYPTED_FILE"

    echo ""
    format_printf "Commands: q:quit, r:refresh, <number>:copy code" "magenta" "bold"
}

# Cleanup function
cleanup_and_exit() {
    [[ -f "$DECRYPTED_FILE" ]] && { rm -P "$DECRYPTED_FILE" 2>/dev/null || rm "$DECRYPTED_FILE"; }
    unset GAUTH_PASSWORD
    echo ""
    info_printf "Exiting TOTP viewer. Goodbye!"
    exit 0
}

# Main
trap "cleanup_and_exit" SIGINT
get_password || exit 1
decrypt_file || exit 1

while true; do
    clear_and_display
    echo ""
    read -r "key?Enter command: "
    if [[ "$key" =~ ^[Qq]$ ]]; then
        cleanup_and_exit
    elif [[ "$key" =~ ^[Rr]$ ]]; then
        continue   # redraw
    elif [[ "$key" =~ ^[0-9]+$ ]]; then
        local counter=1
        while IFS=: read -r name secret || [[ -n "$name" ]]; do
            [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
            name=$(echo "$name" | tr -d '[:space:]')
            secret=$(echo "$secret" | tr -d '[:space:]')
            [[ -z "$secret" ]] && continue
            if [[ $counter -eq $key ]]; then
                totp=$(generate_current_totp "$secret")
                if copy_to_clipboard "$totp"; then
                    success_printf "Copied TOTP for $name to clipboard!"
                else
                    error_printf "Clipboard tool not available"
                    format_printf "TOTP for $name: $totp" "green" "bold"
                fi
                sleep 1
                break
            fi
            counter=$((counter + 1))
        done < "$DECRYPTED_FILE"
    fi
    echo ""
done

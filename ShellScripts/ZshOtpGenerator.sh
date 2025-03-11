#!/usr/bin/env zsh
# Check if oath-toolkit is installed
if ! command -v oathtool &> /dev/null; then
    printf "Error: oathtool is required but not installed.\n"
    printf "Please install oath-toolkit package:\n"
    printf "  - On Debian/Ubuntu: sudo apt-get install oath-toolkit\n"
    printf "  - On macOS: brew install oath-toolkit\n"
    printf "  - On Fedora: sudo dnf install oath-toolkit\n"
    exit 1
fi

TOTP_FILE="$HOME/.otp_secrets_zsh.txt"
# Check if file exists and is readable
if [[ ! -r "$TOTP_FILE" ]]; then
    printf "Error: Cannot read file '%s'\n" "$TOTP_FILE"
    exit 1
fi

# TOTP period in seconds (typically 30)
TOTP_PERIOD=30

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to calculate seconds until next TOTP rotation
calculate_seconds_remaining() {
    local current_time=$(date +%s)
    echo $(( TOTP_PERIOD - (current_time % TOTP_PERIOD) ))
}

# Function to generate TOTP code for current time
generate_current_totp() {
    local secret="$1"
    oathtool --totp --base32 "$secret" 2>/dev/null
}

# Function to generate TOTP code for next period
generate_next_totp() {
    local secret="$1"
    local current_time=$(date +%s)
    local next_period=$((current_time + TOTP_PERIOD - (current_time % TOTP_PERIOD)))
    
    # Use the --at option with a time string format that oathtool accepts
    local next_time_str=$(date -u -d "@$next_period" "+%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -r "$next_period" "+%Y-%m-%dT%H:%M:%SZ")
    oathtool --totp --base32 --now="$next_time_str" "$secret" 2>/dev/null
}

# Copy to clipboard function
copy_to_clipboard() {
    local text="$1"
    if command -v pbcopy &> /dev/null; then
        # macOS
        echo -n "$text" | pbcopy
    elif command -v xclip &> /dev/null; then
        # Linux with X11
        echo -n "$text" | xclip -selection clipboard
    elif command -v wl-copy &> /dev/null; then
        # Linux with Wayland
        echo -n "$text" | wl-copy
    elif command -v clip.exe &> /dev/null; then
        # Windows WSL
        echo -n "$text" | clip.exe
    else
        return 1
    fi
    return 0
}

# Display progress bar for remaining time
display_progress_bar() {
    local seconds_remaining=$1
    local bar_length=20
    local filled_length=$(( (TOTP_PERIOD - seconds_remaining) * bar_length / TOTP_PERIOD ))
    local empty_length=$(( bar_length - filled_length ))
    
    printf "["
    printf "%${filled_length}s" | tr ' ' '='
    printf ">"
    printf "%${empty_length}s" | tr ' ' ' '
    printf "] %d/%d sec" "$seconds_remaining" "$TOTP_PERIOD"
}

# Clear screen and display TOTPs in a loop
clear_and_display() {
    clear
    local seconds_remaining=$(calculate_seconds_remaining)
    local current_date=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Display header with time and progress bar
    printf "${BLUE}TOTP Codes - $current_date${NC}\n"
    printf "Time until next rotation: "
    display_progress_bar "$seconds_remaining"
    printf "\n\n"
    
    # Display the table
    printf "${CYAN}%-4s %-30s %-16s %-16s %s${NC}\n" "No." "Key Name" "Current TOTP" "Next TOTP" "Actions"
    printf "%-4s %-30s %-16s %-16s %s\n" "----" "$(printf '%0.s-' {1..30})" "$(printf '%0.s-' {1..16})" "$(printf '%0.s-' {1..16})" "-------"
    
    # Read each line from the file
    local counter=1
    while IFS=: read -r name secret || [[ -n "$name" ]]; do
        # Skip empty lines and comments
        [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
        
        # Remove any whitespace
        name=$(echo "$name" | tr -d '[:space:]')
        secret=$(echo "$secret" | tr -d '[:space:]')
        
        # Skip invalid lines
        [[ -z "$secret" ]] && continue
        
        # Generate current and next TOTP
        current_totp=$(generate_current_totp "$secret")
        next_totp=$(generate_next_totp "$secret")
        
        # Format the output - with color highlight for low time
        if [[ $seconds_remaining -le 5 ]]; then
            printf "${YELLOW}%-4d %-30s ${RED}%-16s${NC} %-16s" "$counter" "$name" "$current_totp" "$next_totp"
        else
            printf "%-4d %-30s ${GREEN}%-16s${NC} %-16s" "$counter" "$name" "$current_totp" "$next_totp"
        fi
        
        # Add action indicators
        printf " [${counter}:copy]"
        printf "\n"
        
        counter=$((counter + 1))
    done < "$TOTP_FILE"
    
    # Help text at bottom
    printf "\n${PURPLE}Commands: q:quit, r:refresh, <number>:copy code${NC}\n"
    
    # Return the seconds remaining so the main loop can use it
    return $seconds_remaining
}

# Function to ask user if they want to quit
ask_to_quit() {
    echo ""
    read -r -k 1 "response?TOTP period ended. Would you like to quit? (y/n): "
    echo ""
    if [[ "$response" =~ ^[Yy]$ ]]; then
        exit 0
    fi
}

# Function to handle key presses
handle_key_press() {
    local key="$1"
    local num_entries=$(grep -v '^#' "$TOTP_FILE" | grep -v '^\s*$' | wc -l)
    
    if [[ "$key" =~ ^[Qq]$ ]]; then
        # Quit
        exit 0
    elif [[ "$key" =~ ^[Rr]$ ]]; then
        # Refresh (do nothing, loop will refresh)
        return
    elif [[ "$key" =~ ^[0-9]+$ ]] && [[ "$key" -le "$num_entries" ]] && [[ "$key" -gt 0 ]]; then
        # Copy the current TOTP for the selected entry
        local selected_item="$key"
        local counter=1
        local selected_totp=""
        
        while IFS=: read -r name secret || [[ -n "$name" ]]; do
            # Skip empty lines and comments
            [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
            
            # Remove whitespace
            name=$(echo "$name" | tr -d '[:space:]')
            secret=$(echo "$secret" | tr -d '[:space:]')
            
            # Skip invalid lines
            [[ -z "$secret" ]] && continue
            
            if [[ $counter -eq $selected_item ]]; then
                selected_totp=$(generate_current_totp "$secret")
                selected_name="$name"
                break
            fi
            
            counter=$((counter + 1))
        done < "$TOTP_FILE"
        
        if [[ -n "$selected_totp" ]]; then
            if copy_to_clipboard "$selected_totp"; then
                echo -e "\n${GREEN}Copied TOTP for $selected_name to clipboard!${NC}"
                sleep 1
            else
                echo -e "\n${YELLOW}Could not copy to clipboard - clipboard tool not available${NC}"
                echo -e "TOTP for $selected_name: ${GREEN}$selected_totp${NC}"
                sleep 2
            fi
        fi
    fi
}

# Enable non-blocking input
if [[ $ZSH_VERSION ]]; then
    # For zsh
    enable_non_blocking() {
        zmodload zsh/zle
        read_key() {
            local key
            if read -t 0.1 -k 1 key; then
                echo "$key"
                return 0
            fi
            return 1
        }
    }
else
    # For bash
    enable_non_blocking() {
        read_key() {
            local key
            read -t 0.1 -n 1 key
            if [[ -n "$key" ]]; then
                echo "$key"
                return 0
            fi
            return 1
        }
    }
fi

enable_non_blocking

# Trap Ctrl+C to exit gracefully
trap "echo -e \"\n${BLUE}Exiting TOTP viewer. Goodbye!${NC}\"; exit 0" SIGINT

# Print startup message
echo "Starting TOTP viewer..."
echo "Press 'q' to quit anytime"
sleep 1

# Main loop
while true; do
    clear_and_display
    seconds_remaining=$?
    
    # Check for key presses (non-blocking)
    key=$(read_key 2>/dev/null)
    if [[ -n "$key" ]]; then
        handle_key_press "$key"
    fi
    
    # If seconds remaining is 0 or 1, ask if user wants to quit
    if [[ $seconds_remaining -le 1 ]]; then
        ask_to_quit
    fi
    
    sleep 0.5  # Shorter sleep for more responsive input
done

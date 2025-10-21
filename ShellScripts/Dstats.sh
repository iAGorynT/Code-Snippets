#!/bin/zsh
# Function to convert bytes to human-readable format
human_readable_size() {
    local bytes=$1
    local -a units=('B' 'KB' 'MB' 'GB' 'TB')
    local i=0
    local size=$bytes
    [[ $bytes -eq 0 ]] && echo "0 B" && return
    while (( size > 1024 && i < 4 )); do
        size=$(echo "scale=2; $size / 1024" | bc)
        (( i++ ))
    done
    printf "\033[36m%.2f %s\033[0m" "$size" "${units[$i+1]}"
}

# Function to get Mac OS disk space information, including purgeable space
get_mac_disk_space() {
    local mount_point="/"
    
    # Get disk information
    local storage_info=$(system_profiler SPStorageDataType)
    local total_size=$(echo "$storage_info" | grep "Capacity:" | head -1 | awk '{print $2 " " $3}')
    local free_size=$(echo "$storage_info" | grep "Free:" | head -1 | awk '{print $2 " " $3}')
    
    # Get byte values using df
    local total_bytes=$(df -b "$mount_point" | tail -1 | awk '{print $2}')
    local free_bytes=$(df -b "$mount_point" | tail -1 | awk '{print $4}')
    
    # Get purgeable space using diskutil
    local purgeable_space=$(diskutil info "$mount_point" | grep "Purgeable Space" | awk -F ': ' '{print $2}')
   
    clear
    echo "\033[33;1mDisk Detail Information...\033[0m"
    echo

    # Disk Stats
    echo "\033[33;1mMac OS Disk Space Information:\033[0m"
    echo "\033[33m----------------------------\033[0m"
    printf "Total Disk Space: \033[36m%-15s\033[0m\n" "$total_size"
    printf "Free Disk Space:  \033[36m%-15s\033[0m\n" "$free_size"
    printf "Purgeable Space:  \033[36m%-15s\033[0m\n" "$purgeable_space"
    
    # Detailed breakdown
    echo -e "\n\033[33;1mDetailed Breakdown:\033[0m"
    echo "\033[33m-------------------\033[0m"
    printf "Total Disk Space: %s\n" "$(human_readable_size "$total_bytes")"
    printf "Free Disk Space:  %s\n" "$(human_readable_size "$free_bytes")"
    
    # Calculate percentage
    if [[ $total_bytes -gt 0 ]]; then
        local percentage=$(echo "scale=2; ($free_bytes / $total_bytes) * 100" | bc)
        printf "\nPercentage Free: \033[32m%.2f%%\033[0m\n" "$percentage"
    else
        echo "\nCannot calculate percentage (division by zero)"
    fi
    
    # Diskspace Command Output
    # ANSI Colors
    readonly YELLOW="\033[1;33m"
    readonly WHITE="\033[97m"
    readonly CYAN="\033[36m"
    readonly RESET="\033[0m"

    printf "\n"
    # Check if diskspace command exists and works
    if ! command -v diskspace >/dev/null 2>&1 || ! diskspace --version >/dev/null 2>&1; then
        echo "Error: diskspace command not found or not working correctly."
    else
        # Header
        echo "\033[33;1mDisk Space Report\033[0m"
        echo "\033[33m-----------------\033[0m"

        # Run diskspace with cleaner AWK processing
        diskspace --human-readable | awk -v white="$WHITE" -v cyan="$CYAN" -v reset="$RESET" '
        /^(Available|Important|Opportunistic|Total):/ {
            gsub(/:/, ":" reset)
            gsub(/[0-9.]+ [A-Z]+/, cyan "&" reset)
            print white $0 reset
            next
        }
        {print}
        '
    fi

    # Display Macintosh HD Info Window
    shortcuts run "Mac HD Info"
}

# Run the function
get_mac_disk_space

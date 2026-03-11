#!/bin/zsh
# Alias Documentation Listing for Selected Category
# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Required library $FORMAT_LIBRARY not found\n" >&2; exit 1; }
source "$FORMAT_LIBRARY"

# Define categories Array
categories=(
    "General"
    "History"
    "Mac Shutdown / Restart"
    "Java"
    "Particulars CLI"
    "Encrypt / Decrypt"
    "MacVim"
    "MacDown Markdown Editor"
    "Terminal List"
    "Network Speedtest"
    "hdiutil"
    "Preference Pane"
    "Time Machine"
    "SSH"
    "Github"
    "Dev"
    "Homebrew"
    "Main Menu"
    "Quit"
)

# Function to display script header
display_header() {
    clear
    format_printf "Alias Documentation..." "yellow" "bold"
}

# Main Menu Loop
while true; do
    clear
    display_header
    printf "\n" 
    # Select Command Category
    info_printf "Alias Categories:"
    for ((i=1; i<=${#categories[@]}; i++)); do
        printf " %d. %s\n" "$i" "${categories[i]}"
    done
    printf "\n"
    printf "Select Category: "
    read choice

    # Handle Enter Key Pressed (empty input)
    if [[ -z "$choice" ]]; then
        choice=${#categories[@]}
    fi

    # Test if input is numeric and within range
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#categories[@]} )); then
        category="${categories[choice]}"

        # Exit Script If "Quit" Is Choice
        if [[ "$choice" == $((${#categories[@]})) ]]; then
            clear
            success_printf "Alias Documentation Complete..."
            printf "\n"
            exit 0
        fi

        # Build Category Search Strings
        # Start
        catstart="#=> ${category}"  # Plain text for matching
        catend="#=> End ${category}"  # Plain text for matching
        
        # Initialize Variables
        zshrcfile="$HOME/.zshrc"
        start=false
        clear
        
        # Display search information
        info_printf "Searching for: ${catstart} in ${zshrcfile}"
        printf "\n"
        
        while IFS= read -r line; do
            # Check if line begins with Category Start
            if [[ $line == *"#=> ${category}"* ]]; then
                start=true
                format_printf "${catstart}" "green" "bold"
                continue
            fi
            
            # If start is true, display the line
            if [ "$start" = true ]; then
                if [[ $line == *"#=> End ${category}"* ]]; then
                    format_printf "${catend}" "red" "bold"
                    break
                else
                    printf "%s\n" "$line"
                fi
            fi
        done < "$zshrcfile"
        
        printf "\n\n\t\t\tPress any key to continue"
        read -k 1 line
    else
        # Handle Invalid Input
        error_printf "Invalid choice"
        printf "\n\t\t\tPress any key to continue"
        read -k 1 line
    fi
    # Display Main Menu
    clear
# End Main Menu Loop
done

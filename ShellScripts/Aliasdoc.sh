#!/bin/zsh
# Alias Documentation Listing for Selected Category
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
# Main Menu Loop
while true; do
    clear
    echo "Alias Documentation..."
    echo
    # Select Command Category
    echo "Alias Categories:"
    for ((i=1; i<=${#categories[@]}; i++)); do
        echo " $i. ${categories[i]}"
    done
    echo
    echo -n "Select Category: "
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
            echo "Alias Documentation Complete..."
            echo
            exit 0
	fi
# Build Category Search Strings
# Start
        catstart="\e[32m#=> ${category}\e[0m"  # Green color
# End
        catend="\e[31m#=> End ${category}\e[0m"  # Red color
# Initialize Variables
        zshrcfile="$HOME/.zshrc"
        start=false
        clear
        echo -e "\e[34mSearching for:\e[0m $catstart in $zshrcfile"  # Blue color for "Searching for:"
        echo
        while IFS= read -r line; do
# Check if line begins with Category Start
            if [[ $line == *"#=> ${category}"* ]]; then
		start=true
                echo -e "$catstart"
                continue
            fi
# If start is true, display the line
            if [ "$start" = true ]; then
                if [[ $line == *"#=> End ${category}"* ]]; then
                    echo -e "$catend"
                    break
                else
                    echo "$line"
                fi
            fi
        done < "$zshrcfile"
        echo -en "\n\n\t\t\tPress any key to continue"
        read -k 1 line
    else
# Handle Invalid Input
        echo -e '\n\t\t\t\e[1mInvalid choice\e[0m'
        echo -en "\n\t\t\tPress any key to continue"
        read -k 1 line
    fi
# Display Main Menu
    clear
# End Main Menu Loop
done

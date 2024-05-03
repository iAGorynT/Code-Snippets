#!/bin/zsh

# Alias Documentation Listing for Selected Category

clear
echo "Alias Documentation..."
echo

# Main Menu Loop
while true; do
# Select Command Category
    while true; do
        echo "Alias Categories"
        echo " 1. General"
        echo " 2. History"
	echo " 3. Mac Shutdown / Restart"
	echo " 4. Java"
	echo " 5. Particulars CLI"
	echo " 6. MacVim"
	echo " 7. MacDown Markdown Editor"
	echo " 8. Terminal List"
	echo " 9. Network Speedtest"
	echo "10. hdiutil"
	echo "11. Preference Pane"
	echo "12. Time Machine"
	echo "13. SSH"
	echo "14. Mosh"
	echo "15. Github"
	echo "16. Dev"
	echo "17. Homebrew"
	echo "18. Main Menu"
        echo "19. Quit"
        echo

        read -r choice\?"Select Category: "
# Test If Return / Enter Key Pressed; Replace Linefeed Character With Empty Character
        if [[ "$choice" == *$'\n'* ]]; then
            choice=""
        fi

        echo
        case $choice in
             1) category="General"; break;;
             2) category="History"; break;;
             3) category="Mac Shutdown / Restart"; break;;
             4) category="Java"; break;;
	     5) category="Particulars CLI"; break;;
	     6) category="MacVim"; break;;
	     7) category="MacDown Markdown Editor"; break;;
	     8) category="Terminal List"; break;;
	     9) category="Network Speedtest"; break;;
	    10) category="hdiutil"; break;;
	    11) category="Preference Pane"; break;;
	    12) category="Time Machine"; break;;
	    13) category="SSH"; break;;
	    14) category="Mosh"; break;;
	    15) category="Github"; break;;
	    16) category="Dev"; break;;
	    17) category="Homebrew"; break;;
	    18) category="Main Menu"; break;;
            19) clear; echo "Alias Documentation Complete..."; echo; exit 0;;
# Return / Enter Key Pressed
            "") clear; echo "Alias Documentation Complete..."; echo; exit 0;;
             *) clear; echo "Invalid choice"; echo;;
        esac
    done

# Build Category Search Strings
# Start
    catstart="#=> ${category}"
# End
    catend="#=> End ${category}"

# Initialize Variables
    zshrcfile="$HOME/.zshrc"
    start=false

    clear
    echo "Searching for: $catstart in $zshrcfile"
    echo

    while IFS= read -r line; do

# Check if line begins with Category Start
        if [[ $line == *"$catstart"* ]]; then
	    start=true
        fi

# If start is true, display the line
        if [ "$start" = true ]; then
            echo "$line"
        fi

# Check if line begins with Category End
        if [[ $line == *"$catend"* ]]; then
	    break
        fi
    done < "$zshrcfile"

    echo -en "\n\n\t\t\tHit any key to continue"
    read -k 1 line

# Display Main Menu
    clear

# End Main Menu Loop
done


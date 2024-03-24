#!/bin/zsh

# List Selected Days For Month
# This script uses the cal command to get the number of days in the supplied month and year,
# and then loops through each day of the month to check if it is the selected day of the month.
# If the day is the selected day, it prints the date in the format MM/DD/YYYY.

clear
echo "List Selected Days For Month... "
echo

# Prompt user for month, year, and day
read month\?"Enter the two-digit month (01-12): "
read year\?"Enter the four-digit year: "

# Array of days of the week
days=("Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday")

# Prompt the user to select a day
echo "Select a day of the week:"
select daychoice in "${days[@]}"; do
    # Check if the input is valid
    if [[ -n $daychoice ]]; then
        echo "You selected: $daychoice"
	echo
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Validate the input
if [[ $month =~ ^((0[1-9])|(1[0-2]))$ && $year =~ ^[0-9]{4}$ ]]; then

# Calculate the number of days in the month
    days=$(cal $month $year | awk 'NF {DAYS = $NF}; END {print DAYS}')

# Loop through each day of the month
    for ((day=1; day<=$days; day++)); do
        # Get the day of the week for the current day
        dow=$(date -j -f "%m/%d/%Y" "$month/$day/$year" "+%A")

# If the day is the selected day of the week, print the date
        if [ "$dow" = $daychoice ]; then
            echo "$month/$day/$year"
        fi
    done
    echo

else
# Display an error message if the input is invalid
    echo "Invalid input. Please enter a two-digit month (01-12) and a four-digit year."
    echo
fi


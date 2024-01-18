#!/bin/zsh

# List Wednesdays For Month
# This script uses the cal command to get the number of days in the supplied month and year,
# and then loops through each day of the month to check if it is a Wednesday. If the day is
# a Wednesday, it prints the date in the format MM/DD/YYYY.

clear
echo "List Wednesdays For Month... "
echo

# Prompt user for month and year
read month\?"Enter the two-digit month (01-12): "
read year\?"Enter the four-digit year: "
echo

# Validate the input
if [[ $month =~ ^((0[1-9])|(1[0-2]))$ && $year =~ ^[0-9]{4}$ ]]; then

# Calculate the number of days in the month
    days=$(cal $month $year | awk 'NF {DAYS = $NF}; END {print DAYS}')

# Loop through each day of the month
    for ((day=1; day<=$days; day++)); do
        # Get the day of the week for the current day
        dow=$(date -j -f "%m/%d/%Y" "$month/$day/$year" "+%A")

# If the day is Wednesday, print the date
        if [ "$dow" = "Wednesday" ]; then
            echo "$month/$day/$year"
        fi
    done
    echo

else
# Display an error message if the input is invalid
    echo "Invalid input. Please enter a two-digit month (01-12) and a four-digit year."
    echo
fi


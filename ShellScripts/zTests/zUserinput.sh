#!/bin/zsh

# Sample User Input Code - Examples Using Select and Read Statements

clear
echo "Select Statement..."
echo
echo "Do you wish to install this program?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) ans="y"; break;;
        No ) ans="n"; break;;
    esac
done
echo $ans
echo

echo "Read Statement..."
echo
while true; do
    read yn\?"Yy / Nn: "
#   read -p "Do you wish to install this program? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo $yn
echo

echo "Read / Echo Statment..."
echo
while true; do
    echo "Choose an option:"
    echo "1. Option 1"
    echo "2. Option 2"

    read choice

    echo
    case $choice in
        1) echo "Option 1 chosen"; break;;
        2) echo "Option 2 chosen"; break;;
        *) echo "Invalid choice";;
    esac
done
echo

echo "Array / Select Statement..."
echo
echo "Which Option?"
# Define the menu options
array=("Option 1" "Option 2")
# Prompt the user to select an option contained in array values
select choice in "${array[@]}"; do
    case $choice in
        "Option 1")
            echo "You selected Option 1"
            break
            ;;
        "Option 2")
            echo "You selected Option 2"
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
echo

echo "Array / Read / RegEX Validation Statement..."
echo
# Prompt for numeric month
read month\?"Enter month (1-12): "
# Validate month
if [[ $month =~ ^[1-9]$ ]] || [[ $month =~ ^1[0-2]$ ]]
    then 
    echo 'Valid input'
else 
    echo 'Invalid input'
fi
echo "Month entered: $month"
# Lookup table for month names
months=("January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")
# Display the corresponding month name
echo "Month: ${months[$month]}"
echo

echo "Function / RegEX Validation Statement..."
echo
# Validate Phone Number Function
validate_phone_number() {
  local phone_number="$1"
  local regex="^\([0-9]{3}\) [0-9]{3}-[0-9]{4}$"
  if [[ $phone_number =~ $regex ]]; then
    echo "Valid phone number: $phone_number"
  else
    echo "Invalid phone number: $phone_number"
  fi
}
# Enter Phone Number
read phone_number\?"Enter Phone Number (XXX) XXX-XXXX: "
validate_phone_number $phone_number
echo


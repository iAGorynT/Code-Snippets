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


#!/bin/zsh

# Clear the terminal screen
clear

# Display the title of the script
echo "OpenSSL Text Encrypt / Decrypt"
echo " "

# Request User Input for action (encryption or decryption)
while true; do
    read action\?"enc / dec: "
    case $action in
        enc ) break;;    # Encode text
        dec ) break;;    # Decode text
        * ) echo "Please answer enc or dec";;
    esac
done

# Request input for the string to encrypt/decrypt
read string\?"string: "

# Request password input (hidden from view)
read -s password\?"password: "

# Print a newline for better formatting
echo -e "\n"

# Check if all required inputs are provided
if [ -z "$action" ] || [ -z "$string" ] || [ -z "$password" ]
    then 
        echo "You need to set all variables to run the script: enc for encryption or dec for decryption, The string to encrypt/decrypt, The password for the encryption/decryption"
        exit 0
fi

# Perform encryption or decryption based on user input
if [ $action = 'enc' ]
    then
        echo "ENCODE: $string"
        # Encrypt the string using OpenSSL, copy to clipboard, and display
        echo $string | openssl enc -base64 -e -aes-256-cbc -salt -pass pass:$password -pbkdf2 -iter 600000 | tr -d '\n' | pbcopy
        echo
        pbpaste
        echo
elif [ $action = 'dec' ]
    then
        echo "DECODE: $string"
        echo
        # Decrypt the string using OpenSSL and display
        echo $string | openssl enc -base64 -d -aes-256-cbc -salt -pass pass:$password -pbkdf2 -iter 600000
fi

# Print a newline for better formatting
echo -e "\n"

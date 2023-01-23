#!/bin/zsh

clear
echo "OpenSSL Text Encrypt / Decrypt"
echo " "

# Request User Input
read mechanism\?"enc / dec: "
read string\?"string: "
read -s password\?"password: "

# Another way to request input using vared command
#vared -p "enc / dec: " -c mechanism
#vared -p "string: " -c string
#vared -p "password: " -c password

# Skip line
echo -e "\n"

# Check if all parameters are set, if not show an error message and exit the script
if [ -z "$mechanism" ] || [ -z "$string" ] || [ -z "$password" ]
    then echo "You need to set all variables to run the script: enc for encryption or dec for decryption, The string to encrypt/decrypt, The password for the encryption/decryption"
    exit 0
fi

# If the mechanism is encryption => encrypt the string, if the mechanism is decryption => decrypt the string
if [ $mechanism = 'enc' ]
    then
    echo "ENCODE $string"
    echo $string | openssl enc -base64 -e -aes-256-cbc -salt -pass pass:$password -pbkdf2 -iter 100000
elif [ $mechanism = 'dec' ]
    then
    echo "DECODE $string"
    echo $string | openssl enc -base64 -d -aes-256-cbc -salt -pass pass:$password -pbkdf2 -iter 100000
else
    echo "Mechanism (-m) must be enc for encryption or dec for decryption"
fi

# Skip Line
echo -e "\n"

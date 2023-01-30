#!/bin/zsh

clear
echo "OpenSSL Vault Encrypt / Decrypt"
echo " "

# Testing On Desktop
cd $HOME/Desktop

# Request User Input
read action\?"enc / dec: "
read whichvault\?"vault / git: "

# Another way to request input using vared command
#vared -p "enc / dec: " -c action
#vared -p "vault / git: " -c whichvault

# Skip line
echo -e "\n"

# Check if all parameters are set, if not show an error message and exit the script
if [ -z "$action" ] || [ -z "$whichvault" ]
    then echo "You need to set all variables to run the script: enc for encryption or dec for decryption, The vault to encrypt/decrypt: vault for VaultMGR or git for GitMGR"
    echo " "
    exit 0
fi

# Load Hash_CFG
# Set Secret Type
stype="Hash_CFG"
# Set Account
acct=$USER

# Lookup Secret in Keychain
if ! secret=$(security find-generic-password -w -s "$stype" -a "$acct"); then
  echo "Secret Not Found, error $?"
  exit 1
fi

# Set Vault Directory
if [ $whichvault = "vault" ]
    then
    vaultdir="VcaSutL6TsVSj7IrEmOve"
    vaultenc=$vaultdir".enc"
elif [ $whichvault = "git" ]
    then
    vaultdir="GciSttH6UsbSj7IrEMoVe"
    vaultenc=$vaultdir".enc"
else
    echo "Invalid vault to encrypt/decrypt: enter vault for VaultMGR or git for GitMGR"
    echo " "
    exit 0
fi

# Check For Vault Direcory or Encrypted File On Desktop
if [ $action = "enc" ] && [ ! -d $vaultdir ]
    then
    echo "Vault Directory missing on Desktop:" $vaultdir
    echo " "
    exit 0
elif [ $action = "dec" ] && [ ! -f $vaultenc ]
    then
    echo "Encrypted Vault missing on Desktop:" $vaultenc
    echo " "
    exit 0
fi

# If the action is encryption => encrypt the string, if the mechanism is decryption => decrypt the string
if [ $action = 'enc' ]
    then
    tar -cf $vaultdir.tar $vaultdir && gzip $vaultdir.tar && openssl enc -base64 -e -aes-256-cbc -salt -pass pass:$secret -pbkdf2 -iter 100000 -in $vaultdir.tar.gz -out $vaultdir.enc && rm -f $vaultdir.tar.gz
    echo "Vault Encrypted:" $vaultdir
    echo " "
elif [ $action = 'dec' ]
    then
    openssl enc -base64 -d -aes-256-cbc -salt -pass pass:$secret -pbkdf2 -iter 100000 -in $vaultdir.enc -out $vaultdir.tar.gz && tar -xzf $vaultdir.tar.gz && rm -f $vaultdir.tar.gz 
    echo "Vault Decrypted:" $vaultdir
    echo " "
else
    echo "Action must be enc for encryption or dec for decryption"
    echo " "
    exit 0
fi

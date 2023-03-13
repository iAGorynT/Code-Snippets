#!/bin/zsh

clear
echo "OpenSSL Vault Encrypt / Decrypt"
echo " "

# Testing On Desktop
cd $HOME/Desktop

# Request User Input
while true; do
    read action\?"enc / dec: "
    case $action in
        [enc]* ) break;;	# Encode vault
        [dec]* ) break;;	# Decode vault
        * ) echo "Please answer enc or dec";;
    esac
done

while true; do
    read vaultname\?"vmgr / gmgr: "
    case $vaultname in
        [vmgr]* ) break;;	# VaultMGR
        [gmgr]* ) break;;	# GitMGR
        * ) echo "Please answer vmgr or gmgr";;
    esac
done

# Set Vault Variables
if [ $vaultname = "vmgr" ] 
    then
    vaultdir="VcaSutL6TsVSj7IrEmOve" 
    vaultenc=$vaultdir".enc";
elif [ $vaultname = "gmgr" ] 
    then
    vaultdir="GciSttH6UsbSj7IrEMoVe"
    vaultenc=$vaultdir".enc"
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

# Set File Hash
hash_cfg=$(echo $secret | base64 --decode)

# Check For Vault Direcory or Encrypted File On Desktop
if [ $action = "enc" ] && [ ! -d $vaultdir ]
    then
    echo "Vault Directory missing on Desktop:" $vaultdir
    echo " "
    exit 1
elif [ $action = "dec" ] && [ ! -f $vaultenc ]
    then
    echo "Encrypted Vault missing on Desktop:" $vaultenc
    echo " "
    exit 1
fi

# If the action is encryption => encrypt the vault, if the action is decryption => decrypt the vault
if [ $action = 'enc' ]
    then
    tar -cf $vaultdir.tar $vaultdir && gzip $vaultdir.tar && openssl enc -base64 -e -aes-256-cbc -salt -pass pass:$hash_cfg -pbkdf2 -iter 100000 -in $vaultdir.tar.gz -out $vaultdir.enc && rm -f $vaultdir.tar.gz
    echo "Vault Encrypted:" $vaultdir
    echo " "
elif [ $action = 'dec' ]
    then
    openssl enc -base64 -d -aes-256-cbc -salt -pass pass:$hash_cfg -pbkdf2 -iter 100000 -in $vaultdir.enc -out $vaultdir.tar.gz && tar -xzf $vaultdir.tar.gz && rm -f $vaultdir.tar.gz 
    echo "Vault Decrypted:" $vaultdir
    echo " "
fi

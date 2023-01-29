#!/bin/zsh

clear
echo "OpenSSL Vault Encrypt / Decrypt"
echo " "

# Testing On Desktop
cd $HOME/Desktop

# Load Hash_CFG
# Set Secret Type
TYPE="Hash_CFG"
# Set Account
ACCT=$USER

# Lookup Secret in Keychain
if ! SECRET=$(security find-generic-password -w -s "$TYPE" -a "$ACCT"); then
  echo "Secret Not Found, error $?"
  exit 1
fi

# Set Vault Name
VAULT="VcaSutL6TsVSj7IrEmOve"

# Encrypt Vault
#tar -cf $VAULT.tar $VAULT && gzip $VAULT.tar && openssl enc -base64 -e -aes-256-cbc -salt -pass pass:$SECRET -pbkdf2 -iter 100000 -in $VAULT.tar.gz -out $VAULT.enc && rm -f $VAULT.tar.gz

# Decrypt Vault
openssl enc -base64 -d -aes-256-cbc -salt -pass pass:$SECRET -pbkdf2 -iter 100000 -in $VAULT.enc -out $VAULT.tar.gz && tar -xzf $VAULT.tar.gz && rm -f $VAULT.tar.gz 

echo "Vault Encrypted!"
echo " "

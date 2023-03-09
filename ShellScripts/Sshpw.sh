#!/bin/zsh
# Set SSH Hash

clear
echo "Set SSH Hash..."
echo

# Set Secret Type
TYPE="Hash2_CFG"
# Set Account
ACCT=$USER

# Lookup Secret in Keychain
if ! SECRET=$(security find-generic-password -w -s "$TYPE" -a "$ACCT"); then
  echo "Secret Not Found, error $?"
  exit 1
fi

HASH=$(echo $SECRET | base64 --decode)
echo $HASH | sudo -S echo Set...


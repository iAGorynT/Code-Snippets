#!/bin/zsh

# THIS IS TEST CODE THAT WILL BE MERGED INTO Crypvault.sh
# Use Substring Extract to Extract gitMGR Name

# Search Vault/Git JSON Config. File for Filename
str=$(cat $HOME'/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/Config Files/gitmgr_config.json')
#str=$(cat zz.data)
substr="gitmgr_name"
#substr="vaultmgr_name"
prefix=${str%%$substr*}
index=${#prefix}
nameidx=$((index + 14)) # GitMGR
#nameidx=$((index + 16)) # VaultMGR

# Create a SubString That Begins With Vault/Git Filename
str2=$(echo $str | cut -c $nameidx-)

# Strip Special Characters and Save Actual Vault/Git Filename
filename=$(echo $str2 | cut -d '"' -f2)

# Display Working Results
clear
echo "String:    " $str
echo "Substring: " $str2
echo "Filename:  " $filename

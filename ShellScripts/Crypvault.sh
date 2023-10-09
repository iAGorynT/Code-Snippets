#!/bin/zsh

clear
echo "OpenSSL Vault Encrypt / Decrypt"
echo " "

# Set Default Dir To Desktop
cd $HOME/Desktop

# Select Action
echo "Select Action..."
echo " "
select act in "Encrypt" "Decrypt" "Config" "Quit"; do
    case $act in
        Encrypt ) action="enc"; break;;
	Decrypt ) action="dec"; break;;
	Config  ) action="conf"; break;;
	Quit    ) action="quit"; break;;
    esac
done

# Run ConfigFILES Shortcuts App
if [ $action = "conf" ]
    then
    echo " "
    echo "Standby... ConfigFILES Running"
    shortcuts run "ConfigFILES"
    echo "ConfigFILES Complete..."
    echo " "
    exit 0
# Quit Execution of Script
elif [ $action = "quit" ]
    then
    echo " "
    exit 0
fi
    
# Select Vault Type
echo " "
echo "Select Vault Type..."
echo " "
select vnam in "VaultMGR" "GitMGR"; do
    case $vnam in
        VaultMGR ) vaultname="vmgr"; break;;
	GitMGR   ) vaultname="gmgr"; break;;
    esac
done
echo " "

# Confirm that Vault ConfigFILE Encryption Type is OpenSSL
if [ $vaultname = "vmgr" ]
    then
    configfile=$HOME'/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/Config Files/vaultmgr_config.json'
elif [ $vaultname = "gmgr" ]
    then
    configfile=$HOME'/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/Config Files/gitmgr_config.json'
fi
if grep -q -w PFE $configfile
    then 
    echo " "
    echo "Vault Encryption Type is Paranoia PFE, Use VaultMGR or GitMGR..."
    echo " "
    exit 1
fi

# Set Vault Variables
if [ $vaultname = "vmgr" ] 
    then
# If Installed, Use "jq" JSON Processor for Filename Lookup
    if jq -V >/dev/null 2>&1
        then
        filename=$(jq -r .vaultmgr_name $configfile)
    else 
# Search VaultMGR JSON Config. File for Filename
        str=$(cat $configfile)
        substr="vaultmgr_name"
        prefix=${str%%$substr*}
        index=${#prefix}
        nameidx=$((index + 16)) # VaultMGR
# Create a SubString That Begins With VaultMGR Filename
        str2=$(echo $str | cut -c $nameidx-)
# Strip Special Characters and Save Actual VaultMGR Filename
        filename=$(echo $str2 | cut -d '"' -f2)
    fi
# Initialize VaultMGR Names
    vaultdir=$filename
    vaultenc=$vaultdir".enc"
elif [ $vaultname = "gmgr" ] 
    then
# If Installed, Use "jq" JSON Processor for Filename Lookup
    if jq -V >/dev/null 2>&1
        then
        filename=$(jq -r .gitmgr_name $configfile)
    else 
# Search GitMGR JSON Config. File for Filename
        str=$(cat $configfile)
        substr="gitmgr_name"
        prefix=${str%%$substr*}
        index=${#prefix}
        nameidx=$((index + 14)) # GitMGR
# Create a SubString That Begins With GitMGR Filename
        str2=$(echo $str | cut -c $nameidx-)
# Strip Special Characters and Save Actual GitMGR Filename
        filename=$(echo $str2 | cut -d '"' -f2)
    fi
# Initialize GitMGR Names
    vaultdir=$filename
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

# If Decrypting Vault, Move Vault from iCloud to Desktop
iclouddir=$HOME'/Library/Mobile Documents/com~apple~CloudDocs'
icloudenc=$iclouddir/$vaultenc
if [ $action = "dec" ] && [ -f $icloudenc ]
    then
    mv -i $icloudenc $HOME/Desktop
fi

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
    tar -cf $vaultdir.tar $vaultdir && gzip $vaultdir.tar && openssl enc -base64 -e -aes-256-cbc -salt -pass pass:$hash_cfg -pbkdf2 -iter 600000 -in $vaultdir.tar.gz -out $vaultenc && rm -f $vaultdir.tar.gz
# Move encrypted file to iCloud and vault directory to trash
    mv -f $vaultenc $iclouddir
    rm -rf ~/.trash/$vaultdir
    mv -f $vaultdir ~/.trash
    echo "Vault Encrypted:" $vaultdir
    echo "Note:  Encrypted Vault Moved To iCloud, Encrypted Directory Moved To Trash"
    echo " "
elif [ $action = 'dec' ]
    then
    openssl enc -base64 -d -aes-256-cbc -salt -pass pass:$hash_cfg -pbkdf2 -iter 600000 -in $vaultenc -out $vaultdir.tar.gz && tar -xzf $vaultdir.tar.gz && rm -f $vaultdir.tar.gz 
# Move encrypted file to trash
    rm -rf ~/.trash/$vaultenc
    mv -f $vaultenc ~/.trash
    echo "Vault Decrypted:" $vaultdir
    echo "Note:  Encrypted Vault Moved To Trash"
    echo " "
fi

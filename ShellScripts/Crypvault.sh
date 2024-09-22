#!/bin/zsh

# Function to clear screen and display header
display_header() {
    clear
    echo "OpenSSL Vault Encrypt / Decrypt"
    echo " "
}

# Main loop
while true; do
    display_header

    # Set Default Directory To Desktop
    cd $HOME/Desktop

    # Select Action
    echo "Select Action..."
    echo " "
    select act in "Encrypt" "Decrypt" "View" "GitSync" "Backup" "Config" "Quit"; do
        case $act in
            Encrypt ) action="enc"; break;;
            Decrypt ) action="dec"; break;;
            View    ) action="view"; break;;
            GitSync ) action="sync"; break;;
            Backup  ) action="back"; break;;
            Config  ) action="conf"; break;;
            Quit    ) action="quit"; break;;
        esac
    done

    # Check if user wants to quit
    if [ $action = "quit" ]; then
        echo " "
        echo "OpenSSL Vault Enc/Dec Completed"
        exit 0
    fi

    # Run ConfigFILES Shortcuts App
    if [ $action = "view" ]; then
        # Display a warning message when viewing
        osascript -e 'display dialog "WHEN VIEWING, DO NOT UPDATE SELECTED VAULT-Changes will not be saved!" with title "Caution When Viewing" with icon caution buttons {"OK"} default button "OK"' >/dev/null 2>&1
    elif [ $action = "conf" ]; then
        echo " "
        echo "Standby... ConfigFILES Running"
        shortcuts run "ConfigFILES"
        echo "ConfigFILES Complete..."
        echo " "
        continue
    fi
    
    # Select Vault Type
    # All Actions Except Sync
    if [ $action != "sync" ]; then
        echo " "
        echo "Select Vault Type..."
        echo " "
        select vnam in "VaultMGR" "GitMGR"; do
            case $vnam in
                VaultMGR ) vaultname="vmgr"; break;;
                GitMGR   ) vaultname="gmgr"; break;;
            esac
        done
    # Sync Can Only Be Done for GitMGR
    else
        echo " "
        echo "Select Vault Type..."
        echo " "
        select vnam in "GitMGR"; do
            case $vnam in
                GitMGR   ) vaultname="gmgr"; break;;
            esac
        done
    fi
    echo " "

    # Set Vault Configuration File Location
    if [ $vaultname = "vmgr" ]; then
        configfile=$HOME'/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/Config Files/vaultmgr_config.json'
    elif [ $vaultname = "gmgr" ]; then
        configfile=$HOME'/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/Config Files/gitmgr_config.json'
    fi
    
    # Determine Type of Encryption Used on Vault
    if grep -q -w SSL $configfile; then 
        encryptype="SSL"   
    else
        encryptype="PFE"
    fi
    echo "Vault Encryption Used: "$encryptype

    # Set Vault Variables
    if [ $vaultname = "vmgr" ]; then
        # If Installed, Use "jq" JSON Processor for Filename Lookup
        if jq -V >/dev/null 2>&1; then
            filename=$(jq -r '.vaultmgr_name' $configfile)
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
	configjson="vaultmgr_config.json"
    elif [ $vaultname = "gmgr" ]; then
        # If Installed, Use "jq" JSON Processor for Filename Lookup
        if jq -V >/dev/null 2>&1; then
            filename=$(jq -r '.gitmgr_name' $configfile)
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
	configjson="gitmgr_config.json"
    fi

    # Load Hash_CFG
    # Set Secret Type
    stype="Hash_CFG"
    # Set Account
    acct=$USER

    # Lookup Secret in Keychain
    if ! secret=$(security find-generic-password -w -s "$stype" -a "$acct"); then
      echo "Secret Not Found, error $?"
      continue
    fi

    # Set File Hash
    hash_cfg=$(echo $secret | base64 --decode)

    # If Decrypting Vault, Move Vault from iCloud to Desktop
    iclouddir=$HOME'/Library/Mobile Documents/com~apple~CloudDocs'
    icloudenc=$iclouddir/$vaultenc
    if [ $action = "dec" ] && [ -f $icloudenc ]; then
        mv -i $icloudenc $HOME/Desktop
    elif [ $action = "view" ] && [ -f $icloudenc ]; then
        cp -i $icloudenc $HOME/Desktop
    fi

    # Check For Vault Direcory or Encrypted File On Desktop
    if ([ $action = 'enc' ] || [ $action = 'sync' ]) && [ ! -d $vaultdir ]; then
        echo "Vault Directory missing on Desktop:" $vaultdir
        echo " "
	read
        continue
    elif ([ $action = 'dec' ] || [ $action = 'view' ]) && [ ! -f $vaultenc ]; then
        echo "Encrypted Vault missing on Desktop:" $vaultenc
        echo " "
	read
        continue
    fi

    # Perform the selected action
    # Encrypt
    if [ $action = 'enc' ]; then
	if [ $encryptype = 'SSL' ]; then
            # SSL Encrypt
            # Create tar archive, compress with gzip, and encrypt with OpenSSL
            tar -cf $vaultdir.tar $vaultdir && gzip $vaultdir.tar && openssl enc -base64 -e -aes-256-cbc -salt -pass pass:$hash_cfg -pbkdf2 -iter 1000000 -in $vaultdir.tar.gz -out $vaultenc && rm -f $vaultdir.tar.gz
        else
	    # PFE Encrypt
            java -Xmx1g -jar /Applications/Utilities/SSE/ssefenc.jar $vaultdir $hash_cfg twofish
        fi
        # Move encrypted file to iCloud and vault directory to trash
        mv -f $vaultenc $iclouddir
        rm -rf ~/.trash/$vaultdir
        mv -f $vaultdir ~/.trash
        echo "Vault Encrypted:" $vaultdir
        echo "Note:  Encrypted Vault Moved To iCloud, Encrypted Directory Moved To Trash"
        echo " "
    # Decrypt
    elif [ $action = 'dec' ] || [ $action = 'view' ]; then
	if [ $encryptype = 'SSL' ]; then
            # SSL Decrypt
            # Decrypt with OpenSSL, decompress, and extract
            openssl enc -base64 -d -aes-256-cbc -salt -pass pass:$hash_cfg -pbkdf2 -iter 1000000 -in $vaultenc -out $vaultdir.tar.gz && tar -xzf $vaultdir.tar.gz && rm -f $vaultdir.tar.gz 
        else
            # PFE Decrypt
	    java -Xmx1g -jar /Applications/Utilities/SSE/ssefenc.jar $vaultenc $hash_cfg
        fi
        # Move encrypted file to trash
        rm -rf ~/.trash/$vaultenc
        mv -f $vaultenc ~/.trash
        echo "Vault Decrypted:" $vaultdir
        echo "Note:  Encrypted Vault Moved To Trash"
        echo " "
        if [ $action = 'view' ]; then
            echo "When Done Viewing, Move $vaultdir Vault To Trash!"
            echo " "
            # Open unecncrypted vault in finder
            open $HOME/Desktop/$vaultdir
        fi
    # Sync With GitHUB
    elif [ $action = 'sync' ]; then
        clear
        echo "GitHUB Sync Starting"
        currentDate=`date`
        echo $currentDate
        # rsync keeping all file attributes
        rsync -avh $HOME/Documents/GitHub/Code-Snippets/ $HOME/Desktop/GciSttH6UsbSj7I/GitHub/Code-Snippets --delete
        echo "GitHUB Sync Completed"
	read
    # Vault Backup - iCloud to Thumb Drive and Downloads zVault
    elif [ $action = 'back' ]; then
	clear
	echo "Backing up" $vaultdir
	echo " "
	# Set iCloud File Location
	copyfile=$icloudenc
	# Set Vault Config File Location
	copyjson=$configfile
	# Check If Thumb Drive is Mounted (Optional)
	diskutil list external | grep 'Private' &>/dev/null
	MountStatus=$?
	if [ $MountStatus -eq 0 ]; then
	    echo "Backing up to Private..."
	# Copy iCloud Encrypted Vault to BruKasa Thumb Drive if Mounted
	    cp $copyfile /Volumes/Private
	    cp $copyjson /Volumes/Private/Shortcuts\ Config\ Files
	fi
	# Copy iCloud Encrypted Vault to Downloads zVault Backup
	echo "Backing up to Downloads..."
	cp $copyfile $HOME/Downloads/zVault\ Backup
	cp $copyjson $HOME/Downloads/zVault\ Backup/Shortcuts\ Config\ Files	
	echo " "
        echo "Vault Backup Completed"
	read
    fi

    # Pause before next iteration
    echo " "
    echo "Press Enter to continue..."
    read
done

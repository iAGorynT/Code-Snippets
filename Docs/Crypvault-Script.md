## Script: Crypvault.sh
### Desc: OpenSSL Vault Encrypt / Decrypt
Date: 05/13/2024

_Documentation_

This script is a shell script written in zsh.  It is designed to provide functionality for encrypting, decrypting, viewing, syncing, and configuring vaults. Let's break down its functionality step by step:

1. **Clearing Screen and Displaying Header**: The script starts by clearing the terminal screen and displaying a header indicating its purpose: "OpenSSL Vault Encrypt / Decrypt".

2. **Setting Default Directory**: It sets the default directory to the user's desktop.

3. **Selecting Action**: It prompts the user to select an action from a list of options: Encrypt, Decrypt, View, GitSync, Config, and Quit.

4. **Action Handling**: Depending on the selected action, the script performs different tasks:
   - **Encrypt**: Archives the vault directory, gzips it, encrypts it using OpenSSL with AES-256-CBC encryption, and moves the encrypted file to iCloud while moving the original vault directory to the trash.
   - **Decrypt**: Decrypts the encrypted vault file, extracts it, and moves the encrypted file to the trash.
   - **View**: Decrypts the vault file and opens it in Finder. Also, displays a caution message.
   - **GitSync**: Initiates syncing with GitHub by using rsync to mirror a local directory with a corresponding one on GitHub.
   - **Config**: Runs the "ConfigFILES" application.
   - **Quit**: Exits the script.

5. **Vault Type Selection**: Depending on the action, it prompts the user to select the type of vault (VaultMGR or GitMGR).

6. **Config File and Encryption Type Checking**: It checks the configuration file to ensure the encryption type is OpenSSL.

7. **Setting Vault Variables**: Sets variables related to vault directories and filenames based on the selected vault type.

8. **Loading Secret from Keychain**: Retrieves a secret (presumably a password) from the macOS Keychain.

9. **Decrypting or Viewing Vaults**: Decrypts or views the vault based on the action selected by the user.

10. **Moving Files**: Moves files between directories or to the trash based on the action.

11. **Syncing with GitHub**: Initiates syncing with GitHub by mirroring a local directory with a corresponding one on GitHub.

Overall, this script provides a convenient interface for managing encrypted vaults, including encryption, decryption, viewing, and syncing operations, with options for configuring settings and quitting the script.
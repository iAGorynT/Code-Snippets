## Script: Cryptxt.sh
### Desc: OpenSSL Text Encrypt / Decrypt
Date: 05/05/2024

_Documentation_

This script is a shell script written in zsh. It provides a simple interface for encrypting and decrypting text using OpenSSL. Let's break down its functionality:

1. **Clear Screen and Display Title**: The script starts by clearing the screen and displaying a title, "OpenSSL Text Encrypt / Decrypt".

2. **User Input**: It enters a loop where it prompts the user to choose between encryption ("enc") or decryption ("dec"). It repeatedly asks for input until a valid choice is made.

3. **Request Text and Password**: After the user chooses an action, it prompts for the text to be encrypted or decrypted and the password to be used for the encryption/decryption. The password input is masked (hidden) as the user types.

4. **Check Input**: It checks if all necessary parameters (action, string, password) are set. If any of them are missing, it displays an error message and exits the script.

5. **Encrypt or Decrypt**: Depending on the chosen action ("enc" or "dec"), it performs encryption or decryption using OpenSSL.

   - **Encryption**: If the action is encryption, it encrypts the provided string using AES-256-CBC encryption with base64 encoding. It then copies the encrypted text to the clipboard and displays it.
   
   - **Decryption**: If the action is decryption, it decrypts the provided string using AES-256-CBC decryption with base64 decoding. It displays the decrypted text.

6. **Output**: It prints out the encrypted or decrypted text, depending on the chosen action.

7. **Skip Lines**: It adds empty lines for better readability in the terminal.

This script provides a straightforward way to encrypt and decrypt text using OpenSSL with AES-256 encryption. It ensures that the user provides all necessary inputs and handles encryption and decryption accordingly.
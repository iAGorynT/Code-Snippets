#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
[[ -f "$FORMAT_LIBRARY" ]] || { printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2; exit 1; }
source "$FORMAT_LIBRARY"

clear
rocket_printf "Password Extractor..."
printf "\n"

printf "Choose Password Generator:\n"
printf "1) GRC (Web-based)\n"
printf "2) Brukasa (Local Python script)\n"
printf "Enter choice (1 or 2): "
read choice
printf "\n"

if [[ "$choice" == "1" ]]; then
    info_printf "The GRC website will be opened in your default browser."
    info_printf "Please generate a random password with 63 alpha-numeric characters (a-z, A-Z, 0-9) and copy it to the clipboard."
    printf "Press Enter to open the website. "
    read
    open https://www.grc.com/passwords.htm
    printf "Press Enter to continue... "
    read
    printf "\n"
elif [[ "$choice" == "2" ]]; then
    uv run ~/PythonCode/password_gen.py -m -n -l 63
    printf "Press Enter to continue... "
    read
    printf "\n"
else
    error_printf "Invalid choice. Please enter 1 or 2." true
    exit 1
fi

password=$(pbpaste)

if [[ ! "$password" =~ ^[A-Za-z0-9]{63}$ ]]; then
    error_printf "Clipboard must contain exactly 63 alpha-numeric characters (a-z, A-Z, 0-9)." true
    exit 1
fi

info_printf "Full password string: $password"

printf "Enter the length of the substring to extract (1-63): "
read length

if [[ ! "$length" =~ ^[0-9]+$ ]] || (( length < 1 || length > 63 )); then
    error_printf "Please enter a number between 1 and 63." true
    exit 1
fi

max_start=$((63 - length))
start=$((RANDOM % (max_start + 1)))

extracted="${password:$start:$length}"

printf "\n"
success_printf "Extracted substring: $extracted"
printf "\n"

printf "Would you like to save this to the clipboard? (y/n) "
read answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "$extracted" | pbcopy
    success_printf "Saved to clipboard."
fi

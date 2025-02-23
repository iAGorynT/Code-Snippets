#!/bin/zsh

# Source function library with error handling
FORMAT_LIBRARY="$HOME/ShellScripts/FLibFormatPrintf.sh"
if [[ ! -f "$FORMAT_LIBRARY" ]]; then
    printf "Error: Required library %s not found\n" "$FORMAT_LIBRARY" >&2
    exit 1
fi
source "$FORMAT_LIBRARY"

function generate_auth_codes() {
    clear
    format_printf "Gauth Authenticator..." "yellow" "bold"
    printf "\n"
    # Load Hash_CFG
    secret_type="Hash2_CFG"
    account="$USER"
    # Lookup Secret in Keychain
    if ! secret=$(security find-generic-password -w -s "$secret_type" -a "$account"); then
        error_print "Secret Not Found, error $?" true
    fi
    # Set File Hash and Temporary Environment variable
    hash_cfg=$(echo "$secret" | base64 --decode)
    export GAUTH_PASSWORD="$hash_cfg"
    # Run Gauth with password
    Gauth.exp
}

# Main loop
while true; do
    generate_auth_codes
    
    printf "\nRefresh Auth Codes? (y/n): "
    read -rq response
    
    case ${response:l} in  # :l converts to lowercase
        y|yes) continue ;;
        *) break ;;
    esac
done


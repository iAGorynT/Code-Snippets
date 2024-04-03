#!/bin/zsh

# JSON File Utility

clear
echo "JSON File Utility..."
echo

# Prompt for file name
read filename\?"Enter the JSON file name: "

# Function to sanitize a filename, global variable, or directory path
sanitize_input() {
# Replace characters that could be interpreted as special characters
# Preserve global variables and directory paths
    sanitized_input=$(echo "$1" | sed 's/[^A-Za-z0-9._/ ~-]//g')
    echo "$sanitized_input"
}

# Example usage:
input="$filename"
sanitized=$(sanitize_input "$input")
echo "Sanitized input: $sanitized"

# Using "eval" command to take in filename and executes it as if it were typed directly 
# on the command line.
#
# BE ADVISED! USING eval MAY POSE A SECURITY RISK!
# Keep that in mind if you opt for this solution.
# USE THIS CODE AT YOUR OWN PERIL!!!
# Suggest that you only use this solution if script execution is limited 
# to TRUSTED INDIVIDUALS and filename is properly sanitized to avoid security vulnerabilities.
sanitizedfilename="$(eval echo $sanitized)"

# Check if file exists
if [ -f "$sanitizedfilename" ]; then
    # Check if file is JSON
    if [[ "$sanitizedfilename" == *.json ]]; then
	echo
        echo "$sanitizedfilename exists and is a JSON file."
	echo
# Pretty Print
	echo "Pretty Print..."
	jq -M '.' "$sanitizedfilename"
	echo
# Alphabetic List
	echo "Alphabetic List..."
	jq -S '.' "$sanitizedfilename"
	echo
# Reverse Alphabetic List
	echo "Reverse Alphabetic List"
	jq -S '.' "$sanitizedfilename" | jq 'to_entries | reverse | from_entries'
	echo 
    else
	echo
        echo "Error: $sanitizedfilename exists but is not a JSON file."
	echo
	exit 1
    fi
else
    echo
    echo "Error: $sanitizedfilename does not exist."
    echo
    exit 1
fi


## Script: Brewapps.sh
### Desc: List Selected Application Descriptions
Date: 05/13/2024

_Documentation_

This script is a shell script written in zsh. This script is designed to list descriptions of selected applications installed via Homebrew on a macOS system. Let's break down its functionality:

1. **Setting Up**: The script starts with clearing the terminal and printing a header indicating that it's going to display application descriptions.

2. **Defining Applications**: An array named `apps` is created, which contains the names of applications for which descriptions are desired. These applications include "btop", "iperf3", "jq", and others.

3. **Function for Checking Application Presence**: The script defines a function named `contains_app`. This function takes a line as input and checks if that line contains any of the application names stored in the `apps` array. If it finds a match, it prints the line.

4. **Temporary File Setup**: The script creates a temporary file using the `mktemp` command to store the results of Homebrew's `brew desc` command.

5. **Running Homebrew Commands**: The script executes the `brew list` command to get a list of installed packages via Homebrew. Then it runs `brew desc --eval-all` with this list as an argument. The `--eval-all` flag is used to evaluate all provided formulae. The output is piped to `awk`, which formats the output into a key-value pair separated by `=` and then pipes it to `column` for better formatting. The formatted output is then redirected to the temporary file created earlier.

6. **Reading Temporary File**: The script reads the temporary file line by line. For each line, it calls the `contains_app` function to check if it contains the name of any of the applications listed in the `apps` array. If a match is found, the line (which presumably contains the description of the application) is printed.

In summary, this script retrieves descriptions for a predefined list of applications installed via Homebrew and prints them out. It's a handy way to quickly view descriptions of specific applications managed by Homebrew on a macOS system.
## Script: FunctionLibDoc.sh
### Desc: Function Library Documentation
Date: 06/11/2024

_Documentation_

This Z shell (zsh) script lists functions from a specified script file (`FunctionLib.sh`). It reads through the file and extracts sections of text between lines that start with `# Function:` and `# Usage:`. Here is a summary of the functionality:

1. **Initialization**:
   - Clears the terminal screen.
   - Displays a header "Function Library Documentation...".
   - Defines search strings to identify the start (`# Function:`) and end (`# Usage:`) of function descriptions.
   - Specifies the file path for the script to read (`$HOME/ShellScripts/FunctionLib.sh`).

2. **File Existence Check**:
   - Checks if the specified file exists and is readable. If not, it displays an error message and exits.

3. **Reading and Processing the File**:
   - Reads the file line by line.
   - When a line starting with `# Function:` is encountered, it sets a flag (`start`) to true.
   - If the flag is true, it prints the line.
   - When a line starting with `# Usage:` is encountered, it prints the line, then adds a blank line and resets the flag to false.

### Summary of Steps:

1. **Clear the terminal** and display the header.
2. **Set search strings** for identifying function sections.
3. **Check if the target file exists and is readable**.
4. **Read the file line by line**:
   - Start printing lines when `# Function:` is found.
   - Stop printing lines after `# Usage:` and add a blank line.
5. **Exit the script** if the file is not found or readable.

This script is useful for quickly displaying function definitions and their usage from a script file, facilitating easier reference and documentation.
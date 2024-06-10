## Script: FunctionLib.sh
### Desc: Global Function Library
Date: 06/10/2024

_Documentation_

This script defines a function named `format_echo` in a Z shell (zsh) environment. The `format_echo` function is used to format and print text with various styling options, such as bold, underline, and color. Here’s a detailed breakdown of its functionality:

### Function Definition: `format_echo`

#### Description:
The `format_echo` function formats text using the `echo` command with various styling options. It can print messages either as standard output or as a styled "HomeBrew" message.

#### Arguments:
1. **text**: The text string to be formatted and printed.
2. **echotype**: The type of message formatting, either 'brew' for HomeBrew styled messages or 'std' for standard messages.
3. **formats**: One or more formatting options specified by numbers (e.g., 1 for bold, 4 for underline).

#### Usage:
```sh
format_echo "Hello, World!" "brew" 1 4 7
```

This usage example would print "Hello, World!" with the specified formatting options applied.

### Detailed Steps in the Function:

1. **Parameter Handling**:
   - The function takes a text string and an echo type.
   - The remaining arguments are taken as formatting options.
   - The first two arguments are shifted out to leave only the formatting options.

2. **Color Variables**:
   - It defines several color variables (e.g., `BLACK`, `RED`, `GREEN`, etc.) and a `RESET` variable to reset the formatting.

3. **Formatting Options Mapping**:
   - An associative array `format_map` maps numbers to corresponding escape sequences for different formatting styles:
     - `0`: Reset all attributes
     - `1`: Bold
     - `2`: Dim
     - `3`: Italic
     - `4`: Underline
     - `5`: Blink
     - `6`: Reverse
     - `7`: Hidden
     - `8`: Strikethrough

4. **Building Format Sequence**:
   - Initializes an empty string `format_sequence`.
   - Iterates over the provided formatting options and builds the format sequence by appending the corresponding escape sequences from `format_map`.

5. **Printing the Formatted Text**:
   - If `echotype` is 'brew':
     - Prints the text as a HomeBrew styled message with a blue "==>" prefix.
   - Otherwise:
     - Prints the text with the specified formatting options applied.

### Example Output:
Given the usage example:
```sh
format_echo "Hello, World!" "brew" 1 4 7
```

- The text "Hello, World!" would be printed in bold and underlined.
- The prefix "==>" would be in blue if the `echotype` is 'brew'.

This function provides a versatile way to print styled text in the terminal, useful for scripts that need to highlight or format output messages for better readability.
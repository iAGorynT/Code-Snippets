## Script: Aliasdoc.sh
### Desc: Alias Documentation by Selected Category
Date: 05/05/2024

_Documentation_

This script is a shell script written in zsh. It's designed to display documentation for aliases categorized by different topics. Here's a breakdown of its functionality:

1. **Define Categories**: An array named `categories` is defined, containing various categories like "General", "History", "Java", etc.

2. **Main Menu Loop**: The script enters a loop where it repeatedly displays a menu and waits for user input.

3. **Display Menu**: Within the loop, it clears the screen and displays a list of categories numbered from 1 to the total number of categories, allowing the user to choose a category.

4. **Handle Input**: It reads the user's choice. If the choice is empty (user presses Enter), it defaults to the last option, which is "Quit". It checks if the input is a valid number within the range of categories.

5. **Exit Script**: If the user selects the last option ("Quit"), the script exits.

6. **Search for Category**: If a valid category is chosen, the script searches for the corresponding section in the user's `~/.zshrc` file. It sets up search strings for the beginning and end of the category section.

7. **Read and Display Lines**: It reads the `~/.zshrc` file line by line. When it encounters the start of the selected category, it starts displaying lines. When it reaches the end of the category section, it stops.

8. **Continue or Go Back**: After displaying the category's content, it prompts the user to press any key to continue. Then, it clears the screen and goes back to the main menu.

9. **Handle Invalid Input**: If the user enters an invalid choice, it displays an error message and waits for a key press before returning to the main menu.

10. **Repeat**: The loop continues until the user chooses to quit.

This script is useful for quickly accessing documentation for aliases organized by different categories. It's customizable by editing the `categories` array and the corresponding sections in the `~/.zshrc` file.
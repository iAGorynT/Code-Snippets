#!/bin/zsh

# Clear the terminal screen
clear

# Display the title of the script
echo "Color Test..."
echo ""

# Display Color Test
# Loop through text attributes (0 to 8)
for attribute in {0..8}; do
  # Loop through text colors (30 to 37)
  for foreground in {30..37}; do
    # Loop through background colors (40 to 47)
    for background in {40..47}; do
      # Print the escape sequence and a representation of it, then reset formatting
      echo -ne "\e[$attribute;$foreground;$background""m\\\e[$attribute;$foreground;$background""m\e[0;37;40m "
    done
    # Newline after each set of background colors
    echo
  done
done
echo ""


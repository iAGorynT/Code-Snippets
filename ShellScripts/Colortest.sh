#!/bin/zsh

# Clear the terminal screen
clear

# Display the title of the script
echo "Color Test..."
echo " "

# Display Color Test
# Loop through text attributes (0 to 8)
for x in {0..8}; do
# Loop through text colors (30 to 37)
  for i in {30..37}; do
# Loop through background colors (40 to 47)
    for a in {40..47}; do
# Print the escape sequence and a representation of it, then reset formatting
      echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m ";
    done;
# Newline after each set of background colors
    echo;
  done;
done;
echo ""


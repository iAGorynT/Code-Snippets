#!/bin/zsh

# Display .ssh Directory File Contents
clear
echo ".ssh Directory File Contents..."
echo

# Loop Through Files and Display Contents
for file in $HOME/.ssh/*; do 
    if [ -f "$file" ]; then 
        echo "$file Contents..." 
	echo
	cat $file
	echo -en "\n\n\t\t\tHit any key to continue"
	read -k 1 line
	clear
    fi 
done


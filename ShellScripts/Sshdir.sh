#!/bin/zsh

# Display .ssh Directory File Contents
clear
echo ".ssh / zVlt Directory File Contents..."
echo

# Loop Through .ssh Files and Display Contents
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

# Loop Through zVlt Files and Display Contents
for file in $HOME/zVlt/*; do 
    if [ -f "$file" ]; then 
        echo "$file Contents..." 
	echo
	cat $file
	echo -en "\n\n\t\t\tHit any key to continue"
	read -k 1 line
	clear
    fi 
done


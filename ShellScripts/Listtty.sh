#!/bin/zsh

clear
echo "TTY Information..."
echo 

# Display Current Session tty Information
echo "Current Terminal Session: $(tty)"
echo

# Display All tty Information for User
echo "All Terminal Sessions for $USER"  
ls -lha /dev/tty* | grep $USER 
echo 


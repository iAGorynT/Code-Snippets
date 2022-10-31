#!/bin/zsh

clear
echo "Hostname Information..."
echo " "

# Display Hostname
echo "Computer Hostname: " $(hostname -f)
echo " "

# Display IP Addresses 
echo "IP Addresses:"
ifconfig | grep "inet " | grep -v 127.0.0.1
echo " "

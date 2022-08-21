#!/bin/zsh

clear
echo "iPerf Client to Server Speedtest..."
echo "   Pass Server IP Address to Shell Script..."
echo " "

# Display Internal Network IP Address
echo Testing Speed to Server IP Address: $1
echo " "

# Test Network Speed to Server
iPerf3 -c $1


#!/bin/zsh

clear
echo "iPerf Server to Client Speedtest..."
echo "   Pass Server IP Address to Shell Script..."
echo " "

# Display Internal Network IP Address
echo Testing Speed from Server IP Address: $1
echo " "

# Test Network Speed from Server
iPerf3 -c $1 -R


#!/bin/zsh

clear
echo "iPerf Client to Server Speedtest..."
echo "   Passing Server_IP Address to Shell Script using Pasteboard..."
echo " "

SERVER_IP=$(pbpaste)

# Display Internal Network IP Address
echo Testing Speed from Client to Server_IP Address: $SERVER_IP
echo " "

# Test Network Speed to Server
iPerf3 -c $SERVER_IP


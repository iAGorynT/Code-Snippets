#!/bin/zsh

clear
echo "iPerf Server to Client Speedtest..."
echo "   Passing SERVER_IP Address to Shell Script using Pasteboard..."
echo " "

SERVER_IP=$(pbpaste)

# Display Internal Network IP Address
echo Testing Speed from SERVER_IP Address: $SERVER_IP to Client
echo " "

# Test Network Speed from Server
iPerf3 -c $SERVER_IP -R


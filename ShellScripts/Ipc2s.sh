#!/bin/zsh

clear
echo "iPerf Client to Server Speedtest..."
echo "   Passing SERVER_IP Address to Shell Script using Pasteboard..."
echo " "

server_ip=$(pbpaste)

# Display Internal Network IP Address
echo Testing Speed from Client to SERVER_IP Address: $server_ip
echo " "

# Test Network Speed to Server
iPerf3 -c $server_ip


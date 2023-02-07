#!/bin/zsh

clear
echo "iPerf Server to Client Speedtest..."
echo "   Passing SERVER_IP Address to Shell Script using Pasteboard..."
echo " "

server_ip=$(pbpaste)

# Display Internal Network IP Address
echo Testing Speed from SERVER_IP Address: $server_ip to Client
echo " "

# Test Network Speed from Server
iPerf3 -c $server_ip -R


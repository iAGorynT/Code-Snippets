#!/bin/zsh

clear
echo "iPerf Server Startup..."
echo "   Enter Ctl-C to Terminate..."
echo " "

# Copy SERVER_IP to Pasteboard
echo $(ipconfig getifaddr en0) | pbcopy

# Display Internal Network IP Address
echo Server_IP Address: $(ipconfig getifaddr en0)
echo " "

# Startup iPerf Server
iPerf3 -s


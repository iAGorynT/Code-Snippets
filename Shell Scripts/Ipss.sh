#!/bin/zsh

clear
echo "iPerf Server Startup..."
echo "   Enter Ctl-C to Terminate..."
echo " "

# Display Internal Network IP Address
echo Server IP Address: $(ipconfig getifaddr en0)
echo " "

# Startup iPerf Server
iPerf3 -s


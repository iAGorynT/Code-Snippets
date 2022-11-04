#!/bin/zsh

clear
echo "iPerf Server Startup..."
echo "   Enter Ctl-C to Terminate..."
echo " "

# Workaround Code for MacOS 13 pbcopy Problem
echo "Server Initializing..." | pbcopy
echo $(pbpaste)
echo " "

# Copy SERVER_IP to Pasteboard
echo $(ipconfig getifaddr en0) | pbcopy

# Display Internal Network IP Address
echo SERVER_IP Address: $(pbpaste)
echo " "

# Startup iPerf Server - Server will Process 1 Request, then Exit.
# Remove -1 to Enable Multi-Request, Unlimited Listening
# iPerf3 -s -1
iPerf3 -s


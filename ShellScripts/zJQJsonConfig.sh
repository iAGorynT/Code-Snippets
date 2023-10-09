#!/bin/zsh

# Use jq Command Line JSON  Processor to Extract gitMGR Name
file1=$HOME'/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/Config Files/gitmgr_config.json'
zzz=$(jq .gitmgr_name $file1)

# Display Working Results
clear
echo $file1
echo $zzz

exit

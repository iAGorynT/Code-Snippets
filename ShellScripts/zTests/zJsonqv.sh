#!/bin/zsh

# JSON File Quick View Utility
# NOTE: Pass the name of a valid JSON File when using - i.e. ./zJsonqv.sh json_filename.json

clear
echo "JSON File Quick View: $1..."
echo

# Pretty Print
echo "Pretty Print..."
jq -M '.' "$1"
echo

# Alphabetic List
echo "Alphabetic List..."
jq -S '.' "$1"
echo

# Reverse Alphabetic List
echo "Reverse Alphabetic List"
jq -S '.' "$1" | jq 'to_entries | reverse | from_entries'
echo 


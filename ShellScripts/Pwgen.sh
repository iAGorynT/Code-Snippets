#!/bin/zsh

# Generate Random Password

clear
echo "Generate Random Password"
echo " "

num=32
if [ x"${1}" = x"-n" ]; then
  num=$2
fi
LANG=C tr -dc '[:print:]' </dev/urandom | head -c ${num} | pbcopy

pbpaste
echo " "

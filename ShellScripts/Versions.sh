#!/bin/bash

# Display Software Versions
clear
echo "Software Versions..."
echo

# Bash
echo "Bash: $BASH_VERSION"

# Zsh
echo "Zsh: $(zsh --version)"

# SSH
# Had to run ssh command and pipe it to echo -n (no new line)
# in order to get results on one line.  Just trying to echo
# produced 2 line output.
ssh -V | echo -n "OpenSSH: "

# OpenSSL
echo "OpenSSL: $(openssl version)"

echo

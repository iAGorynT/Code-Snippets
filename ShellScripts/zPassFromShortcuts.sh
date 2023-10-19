#!/bin/zsh

# THIS IS A SHORTCUTS APP TEST SHOWING THE PASSING OF A RESULT BACK TO A SHELL SCRIPT
clear

# shortcuts run "Pass Result to Shell Script" | cat
a=$(shortcuts run "Pass Result to Shell Script")
echo $a
echo

exit

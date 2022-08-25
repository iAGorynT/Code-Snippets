#!/bin/zsh

# Start Time Machine Backup
clear
echo "Time Machine Backup"
echo " "
echo "Starting Time Machine Backup..."
tmutil startbackup

# Open Time Machine Preference Pane
echo "Openning Time Machine Preference Pane..."
open -b com.apple.systempreferences /System/Library/PreferencePanes/TimeMachine.prefPane
echo " "

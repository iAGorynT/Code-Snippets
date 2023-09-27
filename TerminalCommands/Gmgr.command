#! /bin/zsh

# Minimize All Terminal Windows
osascript -e 'tell application "Terminal" to set miniaturized of every window to true'

# Run Shortcuts App GitMGR Launcher
shortcuts run "GitMGR Launcher"

exit

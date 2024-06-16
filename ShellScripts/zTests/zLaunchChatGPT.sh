#!/bin/zsh

# Test Launching of ChatGPT Desktop App or ChatGPT Web App
# Depending On Which Apps Are Installed On Mac.

clear
echo "ChatGPT Launching..."
echo " "

# Launch ChatGPT Desktop App 1st if installed on Mac
launchapp="/Applications/ChatGPT.app"			# Apple Silicon
echo "Deaktop:" $launchapp
if [[ -r "$launchapp" ]]; then
    Open -j $launchapp					# Launch Desktop App - Hidden
    echo "ChatGPT Desktop Launched in Hidden State..."
    echo
    exit
fi

# Launch ChatGPT Web App 2nd if Desktop App not installed and Web App installed on Mac
launchapp=$HOME"/Applications/ChatGPT.app" 		# Intel / Apple Silicon
echo "Webapp: " $launchapp
if [[ -r "$launchapp" ]]; then
    Open $launchapp					# Launch Web App - Viewable
    echo "ChatGPT Web Launched in Viewable State..."
    echo
    exit
fi

# ChatGPT Not Installed / Launched
echo "ChatGPT Not Installed / Launched..."
echo


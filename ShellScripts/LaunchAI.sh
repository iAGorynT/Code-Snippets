#!/bin/zsh

# Launch Selected AI Chatbot

clear
echo "Launching AI..."
echo 

# Select Chatbot
echo "Select AI Chatbot..."
echo
select act in "ChatGPT" "Copilot" "Gemini" "Quit"; do
    case $act in
        ChatGPT ) action="chatgpt"; break;;
	Copilot ) action="copilot"; break;;
	Gemini  ) action="gemini"; break;;
	Quit    ) action="quit"; break;;
    esac
done
echo

# Launch ChatGPT
if [ $action = "chatgpt" ]
    then

# Search System's Application Folder; Launch ChatGPT Desktop App if installed
    launchapp="/Applications/ChatGPT.app"
    if [ -r "$launchapp" ]; then
        Open -j $launchapp				# Launch "Hidden" Desktop App
        echo "ChatGPT Desktop Launched in Hidden State..."
        echo
        exit 0
    fi

# Search User's Application Folder; Launch ChatGPT Web App if installed
    launchapp=$HOME"/Applications/ChatGPT.app"
    if [ -r "$launchapp" ]; then
        Open $launchapp					# Launch "Viewable" Web App 
        echo "ChatGPT Web Launched in Viewable State..."
        echo
        exit 0
    fi

# ChatGPT Not Installed / Launched
    echo "ChatGPT Not Installed / Launched..."
    echo
    exit 0

# Launch Copilot
elif [ $action = "copilot" ]
    then

# Search User's Application Folder; Launch Copilot Web App if installed
    launchapp=$HOME"/Applications/Copilot.app"
    if [ -r "$launchapp" ]; then
        Open $launchapp					# Launch "Viewable" Web App 
        echo "Copilot Web Launched in Viewable State..."
        echo
        exit 0
    fi

# Copilot Not Installed / Launched
    echo "Copilot Not Installed / Launched..."
    echo
    exit 0

# Launch Gemini
elif [ $action = "gemini" ]
    then

# Search User's Application Folder; Launch Gemini Web App if installed
    launchapp=$HOME"/Applications/Gemini.app"
    if [ -r "$launchapp" ]; then
        Open $launchapp					# Launch "Viewable" Web App 
        echo "Gemini Web Launched in Viewable State..."
        echo
        exit 0
    fi

# Gemini Not Installed / Launched
    echo "Gemini Not Installed / Launched..."
    echo
    exit 0

# Quit Execution of Script
elif [ $action = "quit" ]
    then
    echo "Launching AI Quit..."
    echo " "
    exit 0
fi


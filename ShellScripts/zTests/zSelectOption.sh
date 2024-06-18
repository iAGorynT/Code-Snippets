#!/bin/zsh

# Use osascript to display the dropdown selection box
selected_choice=$(osascript <<EOF
set the_choices to {"Option 1", "Option 2", "Option 3"}
set the_result to choose from list the_choices with title "Select an Option" with prompt "Please choose one of the following options:" OK button name "OK" cancel button name "Cancel"
if the_result is false then
    return "Cancelled"
else
    return item 1 of the_result
end if
EOF
)

# Echo the selected choice
if [[ "$selected_choice" == "Cancelled" ]]; then
    echo "No option selected."
else
    echo "You selected: $selected_choice"
fi


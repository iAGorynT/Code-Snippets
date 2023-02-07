#!/bin/zsh
# Calculate Monitor PPI

clear
echo "Calculate Monitor PPI..."
echo

# Horizontal Resolution
unset reply
echo "Enter Horizontal Resolution (i.e. 2560)"
until [[ $reply =~ ^[0-9]{1,10}$ ]]; do
#   read -p 'Digit: '
    read reply\?"HRes: "
done
echo "You entered: $reply"
echo
hres=$reply

# Vertical Resolution
unset reply
echo "Enter Vertical Resolution (i.e. 1600)"
until [[ $reply =~ ^[0-9]{1,10}$ ]]; do
#   read -p 'Digit: '
    read reply\?"VRes: "
done
echo "You entered: $reply"
echo
vres=$reply

# Monitor Diagonal
unset reply
echo "Enter Monitor Diagonal (i.e. 27.0, 13.3)"
until [[ $reply =~ ^[0-9]*(\.[0-9]+){1,10}$ ]]; do
#   read -p 'Digit: '
    read reply\?"Diag: "
done
echo "You entered: $reply"
echo
diag=$reply

# Note: Remove scale-=2 and add -l to bc command for default scaling
echo "Monitor PPI..."
echo "a=sqrt("$hres"^2 + "$vres"^2) / "$diag" + .005; scale=2; a/1" | bc -l
echo
echo "Note: Monitor Scaling May Impact Mac Performance if PPI is between 120 and 200."
echo

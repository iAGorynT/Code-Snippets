#!/bin/zsh
# Calculate Monitor PPI

clear
echo "Calculate Monitor PPI..."
echo

# Horizontal Resolution
unset REPLY
echo "Enter Horizontal Resolution (i.e. 2560)"
until [[ $REPLY =~ ^[0-9]{1,10}$ ]]; do
#   read -p 'Digit: '
    read REPLY\?"HRes: "
done
echo "You entered: $REPLY"
echo
hres=$REPLY

# Vertical Resolution
unset REPLY
echo "Enter Vertical Resolution (i.e. 1600)"
until [[ $REPLY =~ ^[0-9]{1,10}$ ]]; do
#   read -p 'Digit: '
    read REPLY\?"VRes: "
done
echo "You entered: $REPLY"
echo
vres=$REPLY

# Monitor Diagonal
unset REPLY
echo "Enter Monitor Diagonal (i.e. 27.0, 13.3)"
until [[ $REPLY =~ ^[0-9]*(\.[0-9]+){1,10}$ ]]; do
#   read -p 'Digit: '
    read REPLY\?"Diag: "
done
echo "You entered: $REPLY"
echo
diag=$REPLY

# Note: Remove scale-=2 and add -l to bc command for default scaling
echo "Monitor PPI..."
echo "a=sqrt("$hres"^2 + "$vres"^2) / "$diag" + .005; scale=2; a/1" | bc -l
echo

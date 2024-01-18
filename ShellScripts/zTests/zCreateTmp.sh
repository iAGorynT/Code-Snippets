#!/bin/zsh

clear

# Create Temporary Shell Script For Testing
cd $HOME/ShellScripts/zTests
echo "#!/bin/zsh" > zTmp.sh
chmod 755 zTmp.sh
echo "Temporary File Created..."
echo 
ls -l zTmp.sh

# Wait For 2 Seconds and Open Temporary File in MacVim
sleep 2
echo
open -a MacVim.app zTmp.sh


# Shell Scripts

All Personal Shell Scripts are usually placed in /usr/local/bin, unless you don't want other users 
to have access to them, in which case $HOME/bin.

/usr/local/bin may be in the default PATH, but $HOME/bin will certainly need to be added to PATH.

Adding $HOME/bin to PATH:
export PATH=$PATH:~/bin

You may find it helpful to create a Symbolic Link in your $HOME dirctory to the /usr/local/bin directory to
make thins easier and more seamless when working with your Shell Scripts.

Creating a Symbolic Link:
ln -s /usr/local/bin $HOME/ShellScripts
ln -s $HOME/bin $HOME/ShellScripts

Modified: 8/22/2022 18:13 

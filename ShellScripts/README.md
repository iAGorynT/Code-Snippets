# Shell Scripts

All Personal Shell Scripts are usually placed in /usr/local/bin, unless you don't want other users 
to have access to them, in which case $HOME/bin.

/usr/local/bin may be in the default PATH, but $HOME/bin will certainly need to be added to PATH.

Adding $HOME/bin to PATH:
```shell
export PATH=$PATH:~/bin
```

You may find it helpful to create a Symbolic Link in your $HOME dirctory to the /usr/local/bin directory to
make things easier and more seamless when working with your Shell Scripts.

Creating a Symbolic Link:
```shell
ln -s /usr/local/bin $HOME/ShellScripts
ln -s $HOME/bin $HOME/ShellScripts
```

**Tip**: Mm.sh is the "Main Menu" script that is linked to many of the shell scripts contained in this folder.

_Modified: 07/13/2025 18:31_ 

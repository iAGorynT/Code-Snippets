# Set PATH
export PATH=$PATH:~/bin

# General Commands
alias calias="clear; cat ~/.zshrc | more"
alias clr="clear"

# History Commands
# Search Last 200 History Commands (To Execute a Displayed Command Enter "!<Line #> ie !1031")
# Ctl-R will perform reverse search in MacOS Terminal app
alias hg='history | tail -200 | grep -i'

# Java Commands
alias jh="/usr/libexec/java_home -V"
alias jv="java --version"
alias jvm="ls -a1 /Library/Java/JavaVirtualMachines/"
alias jvmcd="cd /Library/Java/JavaVirtualMachines; ls -a1"
alias jvmrm="sudo rm -rf %1"

# Launch macVim Editor From Terminal Command Prompt
alias mvedit="open -a MacVim.app $1"
# Open Netrw File Explorer in Home Directory 
alias mvexplore="Mvexplore.sh"

# Terminal List Commands
alias la="ls -a"
alias ll="ls -al"
alias ss="cd ShellScripts; la"

# Network Speedtest Commands
# iPerf - Internal Network
alias ipm="Ipm.sh"
alias ipss="Ipss.sh"
alias ipc2s="Ipc2s.sh"
alias ips2c="Ips2c.sh"
# Internet Speedtest"
alias webspeed="open -a Speedtest.app"

# hdituil Commands
alias sbcompact="hdiutil compact -batteryallowed $1"

# Preference Pane Commands
alias pp="la /system/library/Preferencepanes | more"

# Time Machine Commands
alias tmb="Tmb.sh"

# SSH Commands
alias sshstat="sudo systemsetup -getremotelogin"
alias sshon="sudo systemsetup -setremotelogin on"
alias sshoff="sudo systemsetup -setremotelogin off"

# HomeBrew Commands
alias brewm="Brewm.sh"
alias brewit="Brewit.sh"
alias brewdep="brew deps --formula --installed"


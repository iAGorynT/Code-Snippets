# General Commands
alias ca="clear; cat ~/.zshrc | more"
alias clr="clear"
alias dsleep="pmset displaysleepnow"
alias hname="Hname.sh"			# Display Hostname / IP Addresses
alias penv="printenv | more"		# Display Environment Variables
alias sver="Versions.sh"		# Display Software Versions
alias pkgu="pkgutil --pkgs | more"	# List Installed Packages (i.e. Xcode Command Line Tools)
alias ppi="Ppi.sh"			# Calculate Monitor PPI
alias ws="echo 'Default Shell:' $0"	# Display Default Shell (Which Shell)
alias zp="echo 'zsh Prompt: $PROMPT'"	# Show zsh Prompt Format

# History Commands
# Search Last 200 History Commands (To Execute a Displayed Command Enter "!<Line #> ie !1031")
# Ctl-R will perform reverse search in MacOS Terminal app
alias hg='history | tail -n 200 | grep -i'	# Add Search Phrase (i.e. hg vim)
alias ht='history | tail -n 200'		# List Last Commands

# Mac Shutdown / Retart Commands
# Pass Time Parameter - "now" for immediate, "+<minutes>" to delay for specified number of minutes.
alias macsd="sudo shutdown -h $1"
alias macrs="sudo shutdown -r $1"

# Java Commands
alias jh="/usr/libexec/java_home -V"
alias jv="java --version"
alias jvm="ls -a1 /Library/Java/JavaVirtualMachines/"
alias jvmcd="cd /Library/Java/JavaVirtualMachines; ls -a1"
alias jvmrm="sudo rm -rf %1"

# Particulars CLI Commands
alias pall="clear; particulars -a"	# Display All System Information
alias pnet="clear; particulars -N"	# Display Network Information
alias phelp="clear; particulars --help"	# Display Help

# Encrypt / Decrypt / Security Commands
alias cryptxt="Cryptxt.sh"		# OpenSSL Encrypt / Decrypt Text
alias crypvault="Crypvault.sh"		# OpenSSL Encrypt / Decript Vault
alias pwgen="Pwgen.sh"			# Generate Random Password

# Launch macVim Editor From Terminal Command Prompt
alias mvedit="open -a MacVim.app $1"
# Open Netrw File Explorer in Home Directory 
alias mvexplore="Mvexplore.sh"

# Terminal List Commands
alias la="ls -a"					# List All
alias ll="ls -al"					# Long List
alias ss="clear; cd $HOME/ShellScripts; la"		# Show Scripts
alias sst="clear; cd $HOME/ShellScripts/zTests; la"	# Show Test Scripts
alias lc="echo -n 'Number of Files:'; ls | wc -l" 	# List File Count

# Network Speedtest Commands
# iPerf - Internal Network
alias ipm="Ipm.sh"
alias ipss="Ipss.sh"
alias ipc2s="Ipc2s.sh"
alias ips2c="Ips2c.sh"
# Internet Speedtest
alias webspeed="open -a Speedtest.app"
alias clispeed="clear; echo 'Speedtest in progress...'; speedtest -p no"
# Apple Network Quality Test (Note: RPM = Round Trips Per Minute, RTT = Round Trip Time)
alias netq="clear; networkQuality -v"		# Default Network Interface
alias netqif="clear; networkQuality -v -I $1"	# Network Interface
alias netqs="clear; networkQuality -vs"		# Sequential Test

# hdituil Commands
alias sbcompact="hdiutil compact -batteryallowed $1"

# Preference Pane Commands
alias pp="la /system/library/Preferencepanes | more"

# Time Machine Commands
alias tmb="Tmb.sh"

# SSH Commands
alias sshm="Sshm.sh"
alias sshpw="Sshpw.sh"
alias sshstat="sudo systemsetup -getremotelogin"
alias sshon="sudo systemsetup -setremotelogin on; sudo systemsetup -getremotelogin"
alias sshoff="sudo systemsetup -setremotelogin off; sudo systemsetup -getremotelogin"
alias sshlist="ssh-add -l"
alias sshdir="Sshdir.sh"

# Mosh Commands
# NetCat Network Port Troubleshooting For Mosh Server
alias ncsvr="nc -4 -u -l -v 60013"					# Open Port On Mosh Server
alias nccli='echo "hello world" | nc -4 -v -u $DEV_IP 60013'		# Send Message To Server
# Mosh/SSH Local/Remote DevLoc
# Note: ~/.zshenv contains DECO_DDNS, DEV_IP
alias moshloc="mosh --server='/usr/local/bin/mosh-server' $USER@$DEV_IP"
alias moshrem="mosh --server='/usr/local/bin/mosh-server' $USER@$DECO_DDNS"
alias sshloc="clear; ssh $USER@$DEV_IP"
alias sshrem="clear; ssh $USER@$DECO_DDNS"
# List Mosh/SSH Alias'
alias ra="clear; grep -e '# Mosh/SSH' -e 'mosh ' -e 'ssh ' $HOME/.zshrc | grep -v ‘rc=‘"

# Github Commands
alias gh="open -a 'Github Desktop'"

# Ops Commands
alias opsm="Opsm.sh"

# HomeBrew Commands
alias brewm="Brewm.sh"				# Brew Menu
alias brewit="Brewit.sh"			# Update Homebrew
alias brewdep="clear; brew deps --formula --installed"	# List Dependencies
alias brewdocm="Brewdocm.sh"			# Brew Doctor
alias brewtap="clear; brew tap"			# List All Taps

# Main Menu Commands
alias mm="Mm.sh"
alias mmt="~/bin/zTests/Mmt.sh"


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#=> General Commands
alias ca="clear; cat ~/.zshrc | more"	# Display .zshrc Contents
alias da="Aliasdoc.sh"			# Display .zshrc Contents Using Doc Script
alias clr="clear"			# Clear Screen
alias dsleep="pmset displaysleepnow"	# Put Mac Display To Sleep
alias dstats="Dstats.sh"	        # Display Disk Stats
alias hname="Hname.sh"			# Display Hostname / IP Addresses
alias penv="printenv | more"		# Display Environment Variables
alias sver="Versions.sh"		# Display Software Versions
alias pkgu="pkgutil --pkgs | more"	# List Installed Packages (i.e. Xcode Command Line Tools)
alias ppi="Ppi.sh"			# Calculate Monitor PPI
alias ltty="Listtty.sh"			# List tty Sessions
alias ws="dscl . -read ~/ UserShell"	# Display Default Shell (Which Shell)
alias zp="echo 'zsh Prompt: $PROMPT'"	# Show zsh Prompt Format
#=> End General Commands

#=> History Commands
# Search Last 200 History Commands (To Execute a Displayed Command Enter "!<Line #> ie !1031")
# Ctl-R will perform reverse search in MacOS Terminal app
alias hg='history | tail -n 200 | grep -i'	# Add Search Phrase (i.e. hg vim)
alias ht='history | tail -n 200'		# List Last Commands
#=> End History Commands

#=> Mac Shutdown / Restart Commands
# Pass Time Parameter - "now" for immediate, "+<minutes>" to delay for specified number of minutes.
alias macsd="sudo shutdown -h $1"	# Mac Shutdown
alias macrs="sudo shutdown -r $1"	# Mac Restart
#=> End Mac Shutdown / Restart Commands

#=> Java Commands
alias jh="/usr/libexec/java_home -V"				# Java Home
alias jv="java --version"					# Java Version
alias jvm="ls -a1 /Library/Java/JavaVirtualMachines/"		# Java Virtual Machines
alias jvmcd="cd /Library/Java/JavaVirtualMachines; ls -a1"	# cd to Java Virtual Machines Dir
alias jvmrm="sudo rm -rf $1"					# Remove Java Virtual Machine
#=> End Java Commands

#=> Particulars CLI Commands
alias pall="clear; particulars -a"	# Display All System Information
alias pnet="clear; particulars -N"	# Display Network Information
alias phelp="clear; particulars --help"	# Display Help
#=> End Particulars CLI Commands

#=> Encrypt / Decrypt / Security Commands
alias cryptxt="Cryptxt.sh"		# OpenSSL Encrypt / Decrypt Text
alias crypvault="Crypvault.sh"		# OpenSSL Encrypt / Decript Vault
alias pwgen="Pwgen.sh"			# Generate Random Password
#=> End Encrypt / Decrypt / Security Commands

#=> MacVim Commands
alias mvedit="Mvedit.sh $1"		# Launch macVim Editor From Terminal Command Prompt
alias mvexplore="Mvexplore.sh"		# Open Netrw File Explorer in Home Directory
#=> End MacVim Commands

#=> MacDown Markdown Editor Commands
alias mdedit="Mdedit.sh $1"		# Launch MacDown From Terminal Command Prompt
#=> End MacDown Markdown Editor Commands

#=> Terminal List Commands 
alias la="ls -a"                                                # List All
alias ll="ls -al"					        # Long List - Total at top is Block Count
alias cdh="clear; cd $HOME; pwd; echo; ll"		        # Show Home Directory
alias ss="clear; cd $HOME/ShellScripts; pwd; echo; ll"		# Show Scripts
alias sst="clear; cd $HOME/ShellScripts/zTests; pwd; echo; ll"	# Show Test Scripts
alias lc="echo -n 'Number of Files:'; ls | wc -l" 	        # List File Count
#=> End Terminal List Commands

#=> Network Speedtest Commands
# iPerf - Internal Network
alias ipss="Ipss.sh"				# Start iPerf3 Server
alias ipc2s="Ipc2s.sh"				# Start iPerf3 Client-to-Server Test
alias ips2c="Ips2c.sh"				# Start iPerf3 Server-to-Client Test
# Internet Speedtest
alias webspeed="open -a Speedtest.app"		# Gui Based Speedtest
alias clispeed="clear; echo 'Speedtest in progress...'; speedtest -p yes" # Character Based Speedtest
# Apple Network Quality Test (Note: RPM = Round Trips Per Minute, RTT = Round Trip Time)
alias netq="clear; networkQuality -v"		# Default Network Interface
alias netqif="clear; networkQuality -v -I $1"	# Network Interface
alias netqs="clear; networkQuality -vs"		# Sequential Test
#=> End Network Speedtest Commands

#=> hdiutil Commands
alias sbcompact="hdiutil compact -batteryallowed $1"	# Compact Sparsebundle File
#=> End hdiutil Commands

#=> Preference Pane Commands
alias pp="la /system/library/Preferencepanes | more"	# List Preference Panes
#=> End Preference Pane Commands

#=> Time Machine Commands
alias tmb="Tmb.sh"				# Run Time-Machine Backup
alias tms="Tms.sh"				# List Time Machine Snapshots
alias tmdelete="sudo TmDelete.sh"		# Delete All Time Machine Snapshots
#=> End Time Machine Commands

#=> SSH Commands
alias sshm="Sshm.sh"
alias sshpw="Sshpw.sh"
alias sshstat="sudo systemsetup -getremotelogin"
alias sshon="sudo systemsetup -setremotelogin on; sudo systemsetup -getremotelogin"
alias sshoff="sudo systemsetup -setremotelogin off; sudo systemsetup -getremotelogin"
alias sshlist="ssh-add -l"
alias sshdir="Sshdir.sh"
# NetCat Network Port Troubleshooting For Client/Server Commuication
alias ncsvr="nc -4 -u -l -v 60013"					# Open Port On Server
alias nccli='echo "hello world" | nc -4 -v -u $DEV_IP 60013'		# Send Message To Server
# SSH Local/Remote DevLoc
# Note: ~/.zshenv contains DECO_DDNS, DEV_IP
alias sshloc="clear; ssh -i '$HOME/zVlt/id_ed25519' $USER@$DEV_IP"
alias sshrem="clear; ssh -i '$HOME/zVlt/id_ed25519' $USER@$DECO_DDNS"
# List SSH Alias'
alias ra="clear; grep -e '# SSH' -e 'ssh ' $HOME/.zshrc | grep -v ‘ra=‘"
#=> End SSH Commands

#=> Github Commands
alias ghd="open -a 'Github Desktop'"	# Launch Github Desktop App
alias ghdl="GithubDownloader.sh" 	# Download Github Files
#=> End Github Commands

#=> Dev Commands
alias ztmp="~/bin/zTests/zCreateTmp.sh"		# Create Empty Temporary Shell Script File
alias dsync="Devsync.sh"			# Dev to GitHUB Sync
alias bsum="BackupSummary.sh"			# Crypvault Backup Summary
alias ai="LaunchAI.sh"				# Launch AI Chatbot
alias fedoc="FLibFormatEchoDoc.sh"		# List FLibFormatEcho.sh Documentation
alias fpdoc="FLibFormatPrintfDoc.sh"		# List FLibFormatPrintf.sh Documentation
alias ctest="Colortest.sh"			# Display Color Test
alias webapps="clear; echo 'Web Apps...'; echo; ls --color=never -1 ~/Applications; echo" # List Safari Web Apps
#=> End Dev Commands

#=> Homebrew Commands
alias brewit="Brewit.sh"				# Update Homebrew
alias brewdep="clear; brew deps --formula --installed"	# List Dependencies
alias brewdocm="Brewdocm.sh"				# Brew Doctor
alias brewtap="clear; brew tap"				# List All Taps
alias brewapp="Brewappuninstall.sh"			# Brew App Uninstaller
#=> End Homebrew Commands

#=> Main Menu Commands
alias mm="Mm.sh"				# Main Menu - All Menus
alias mmb="Brewm.sh"				# Brew Menu
alias mmo="Opsm.sh"				# Ops Menu
alias mmi="Ipm.sh"				# Ipm Menu
alias mmt="~/bin/zTests/Mmt.sh"			# Test Menu
# List Menu Alias'
alias mml="clear; grep -e '# Main Menu' -e 'alias mm' $HOME/.zshrc | grep -v ‘mml=‘"
#=> End Main Menu Commands

# Enable Colorized Directory Listings
export CLICOLOR=1

# Activate Zsh Command Prompt Theme / Layout
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Enable Homebrew Shell Completions
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

# Activate Zsh Syntax Highlighting
# NOTE:  Ensure This is at Very End of .zshrc
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


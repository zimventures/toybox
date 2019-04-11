##################################################
# Rob's bash file for OSX
#
# If this isn't getting called when you login, try this: 
#   echo 'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' > ~/.bash_profile
#
##################################################
# Colorize prompt

export PS1="\[\e[36m\]\W\[\e[m\]\[\e[33m\]\`parse_git_branch\`\[\e[m\]\\$ "

#################################################
# Rob's list of trusty aliases
#################################################

################
# OSX Specific #
################
# Because nobody likes BSD's implementation of ps
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias ps='ps -Ao user,pid,%cpu,%mem,vsz,rss,tt,stat,start,time,command'

  # Audio die on your Mac? coreaudiod probably needs some motivation.
  alias sound_restart='sudo killall coreaudiod'

  # Colors? Check. 
  alias ls='ls -alGh'
fi 

# Add tabs to mount output
alias mount='mount | column -t'

# Yes, I'm that lazy.
alias h='history'

# Fire off 5 ICMP requests, waiting only 100ms between
alias pingfast='ping -c 5 -i 0.1'

# Get line count for a file
alias lc='wc -l'

# Disk usage aliases
alias df='df -H'
alias du='du -ch'

# Why type what you don't have to?
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'

##############
# Kubernetes #
##############
# Switch Kubernetes environments for kubectl (local = minikube, int_aws = k8s in AWS, int-oci = k8s in OCI)
alias kube_local='export KUBECTL_NAMESPACE=default; kubectl config use-context minikube'
alias kubectl='kubectl --namespace="$KUBECTL_NAMESPACE"'
alias cube='kubectl --namespace="$KUBECTL_NAMESPACE"'

###############
# Git helpers #
###############
alias git_stat='git diff --stat --color' # add <remote> <local> to the end of this for the complete command
                                         # example: git_stat remote/origin/master my_local_name
alias git_branch='git branch -a -vv'

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history

# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

######################################################################
# Print out a loging banner with some fun stuff
# Uses fortune, cowsay, iStats, and lolcat (ok if missing)
# brew install fortune
# brew install cowsay
# gem install lolcat
# gem install iStats
######################################################################
banner() {

  # Build an output string
  if hash lolcat 2>/dev/null; then
    echo "IP Address: " $(ipconfig getifaddr en0) | lolcat
  else
    echo "IP Address: " $(ipconfig getifaddr en0)
  fi

  if hash istats 2>/dev/null; then

    if hash lolcat 2>/dev/null; then
      eval "istats cpu -f --no-graphs | lolcat"
      eval "istats battery charge --no-graphs | lolcat"
    else
      eval "istats cpu -f"
      eval "istats battery charge"
    fi
  fi

  if hash fortune 2>/dev/null; then
    if hash cowsay 2>/dev/null; then
      if hash lolcat 2>/dev/null; then
        eval "fortune | cowsay | lolcat"
      else
        eval "fortune | cowsay"
      fi
    else
      eval "fortune"
    fi
  fi
}

# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "[${BRANCH}${STAT}]"
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

banner

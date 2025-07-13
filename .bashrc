#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
export PATH="$PATH:/usr/bin/clion-2024.3.5/bin"
export PATH="$PATH:/usr/bin/GoLand-2025.1/bin"
shopt -s histappend  
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"  

export PATH="$PATH:/home/user/.foundry/bin"

export PATH="$PATH:/home/user/.foundry/bin"

export PATH="$PATH:/home/user/.foundry/bin"

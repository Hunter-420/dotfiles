#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vi='nvim'
alias cls='clear'
alias tmka='tmux kill-server'
alias tmls='tmux list'
alias tmns='tmux new -s'
alias tmas='tmux a -t'
alias tmks='tmux kill-session -t'
alias tml='tmux ls'
PS1='[\u@\h \W]\$ '

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

 [ -f ~/.fzf.bash ] && source ~/.fzf.bash
# Read config file only if this variable is set

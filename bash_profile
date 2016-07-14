
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
alias .='nvim $(fzf)'
alias d='cd ~/Development/HTML'
export FZF_DEFAULT_COMMAND='find .'
#export NODE_PATH="/usr/local/lib/node_modules"
export NODE_PATH=/usr/lib/node_modules:$NODE_PATH

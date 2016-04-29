
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
alias .='nvim $(fzf)'
alias d='cd ~/Development/HTML'
export FZF_DEFAULT_COMMAND='find .'

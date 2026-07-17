# Shared Bash Profile

# Set PATH
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/usr/local/opt/python@3.9/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:$HOME/.local/bin"

# Aliases
alias pip=pip3
alias vim=/opt/homebrew/bin/nvim
alias python3="/opt/homebrew/bin/python3.9"

# Load secrets (API tokens, etc.)
[ -f /Users/Shared/dotfiles/shell/.secrets ] && source /Users/Shared/dotfiles/shell/.secrets

# Work/personal-specific config — gitignored, lives in the private overlay
[ -f /Users/Shared/dotfiles/private/shell/private.bash ] && source /Users/Shared/dotfiles/private/shell/private.bash

touch ~/.hushlogin

killport () {
	[ -z "$1" ] && return
	process=$(lsof -i :$1 | grep LISTEN | awk -F' ' '{print $2}')
	if [ -n "$process" ]; then
		echo "killing process $process on $1"
		kill -9 $process
		return
	fi
	echo "nothing running on $1"
}

# Git aliases
alias gco="git checkout"
alias gcm="git commit -m"
alias gs="git status"
alias gpull='git pull'

alias yd='yarn dev'
alias dc='docker-compose up'
alias in='npx inngest-cli@latest dev'
alias dbs='yarn db:studio'

alias mount="$HOME/Documents/scripts/mount-disks.sh"

# Load nvm properly
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# alias brew for multi user
brewser=$(stat -f "%Su" $(which brew) 2>/dev/null)
if [ -n "$brewser" ]; then
	alias brew='sudo -Hu '$brewser' brew'
fi

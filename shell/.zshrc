# Load Zsh Profiling
# zmodload zsh/zprof

# Set PATH
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/usr/local/opt/python@3.9/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$PATH:$HOME/.local/bin"

#git auto complete
# -u: trust Homebrew completion dirs owned by the other user account
autoload -Uz compinit && compinit -u

# Enable tab completion options
setopt AUTO_LIST
setopt AUTO_MENU
setopt COMPLETE_IN_WORD

# Aliases
alias pip=pip3
alias vim=/opt/homebrew/bin/nvim
alias python3="/opt/homebrew/bin/python3"

# Use default emacs keybindings (vi mode disabled)
bindkey -e

# Work/personal-specific config (aliases, team conventions) — gitignored,
# lives in the private overlay. Sourced early so later files can read its env.
[ -f /Users/Shared/dotfiles/private/shell/private.zsh ] && source /Users/Shared/dotfiles/private/shell/private.zsh

# Project-aware pastel prompt
source "/Users/Shared/dotfiles/shell/project-colors.zsh"

# Completion system customization
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

touch ~/.hushlogin

killport () {
	[ ! $1 ] && return
	process=$(lsof -i :$1 | grep LISTEN | awk -F' ' '{print $2}')
	if [[ -n $process ]]
	then
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
alias gp="git push"
alias gd="git diff HEAD"
alias ga="git add ."
alias redeploy="/Users/Shared/dotfiles/scripts/redeploy-preview.sh"
gc() { git commit -am "$*" }
gl() { git log --oneline -n "${1:-10}" }
search() {
  ddgr --np --json -n 10 "$*" 2>/dev/null | /opt/homebrew/bin/python3 -c "
import json, sys
results = json.load(sys.stdin)
for i, r in enumerate(results, 1):
    title = r.get('title', '')
    url = r.get('url', '')
    link = f'\033]8;;{url}\033\\\\{url}\033]8;;\033\\\\'
    print(f'  {i}. {title}')
    print(f'     {link}')
    print()
"
}
alias gpull='git pull'
alias remote='git rev-parse --abbrev-ref --symbolic-full-name @{u}'
alias branches='git for-each-ref --sort=-committerdate --format="%(committerdate:relative)	%(refname:short)" refs/heads/ | head -5'

pull() {
  local remote url
  remote=$(git remote get-url origin 2>/dev/null) || { echo "Not a git repo or no origin remote"; return 1; }
  url=$(echo "$remote" | sed -E 's|git@github\.com:|https://github.com/|; s|\.git$||')
  open "${url}/pulls"
}

pr() {
  local target="${1:-$(git branch --show-current 2>/dev/null)}"
  if [[ -z "$target" ]]; then
    echo "Not in a git repository and no PR number provided."
    return 1
  fi
  local url
  url=$(gh pr view "$target" --json url --jq '.url' 2>/dev/null)
  if [[ -n "$url" ]]; then
    echo "$url"
    echo
    gh pr view "$target"
    return
  fi
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    gh pr view "$target"
    return
  fi
  printf "No pull request exists for this branch. Create one? [y/N] "
  local reply
  read -r reply
  if [[ "$reply" =~ ^[Yy] ]]; then
    gh pr create
  fi
}

prs() {
  if [[ -n "$1" ]]; then
    gh pr list --search "$1"
  else
    gh pr list
  fi
}

alias home='cd ~'
alias dev='cd ~/Development'
alias desk='cd ~/Desktop/'
alias dot='cd /Users/Shared/dotfiles'
alias journal='cd ~/Development/dev-journal'
alias yd='yarn dev'
alias dc='docker-compose up'
alias in='npx inngest-cli@latest dev'
alias dbs='yarn db:studio'
# cc: plain Claude session in the current pane, auto mode (bypasses the wez-claude layout).
# Guard for a TTY first — with non-interactive stdin (e.g. a nested Claude/agent shell)
# claude auto-enters --print mode and dies with a cryptic "Input must be provided" error.
cc() {
  if [[ ! -t 0 ]]; then
    print -u2 "cc: needs an interactive terminal (stdin isn't a TTY — nested Claude shell?)."
    return 1
  fi
  command claude --permission-mode auto "$@"
}

# Pi.dev — enable all built-in tools for agent sessions while leaving package
# management subcommands in the first argument position expected by the CLI.
pi() {
  case "${1:-}" in
    install|remove|uninstall|update|list|config)
      command pi "$@"
      ;;
    *)
      command pi --tools read,bash,edit,write,grep,find,ls "$@"
      ;;
  esac
}

# Enhanced history and keybinding configurations
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# History search
bindkey '^R' history-incremental-search-backward

# Better history navigation
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Improved completion
zstyle ':completion:*' menu select

function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats '%b '

precmd() {
  vcs_info
  _theme_check_reload
  _update_project_prompt
}

setopt PROMPT_SUBST
# PROMPT='${_current_project_prompt}%F{blue}%~%f %F{red}${vcs_info_msg_0_}%f'$'\n''$ '
PROMPT='${_current_cwd_prompt}%F{${ACCENT_BLENDED}}${vcs_info_msg_0_}%f'$'\n'' '

alias mount="$HOME/Documents/scripts/mount-disks.sh"
# Tab completion for mount-disks
compdef _mount_disks mount
_mount_disks() {
  local -a shares
  shares=($(mount-disks list 2>/dev/null))
  _describe "shares" shares
}

# Grid + size + modified date (eza), sorted oldest→newest so the most recent items sit at the bottom.
# Use real terminal width — a fake narrow -w forces one column when names are long.
# --sort=modified is the default; a trailing --sort=... in "$@" overrides it (eza takes the last one).
ls_grid() {
  local w=$(( ${COLUMNS:-0} ))
  (( w < 1 )) && w=$(command tput cols 2>/dev/null || echo 0)
  (( w < 1 )) && w=80
  command eza -G -l --icons=always --no-permissions --no-user --time-style=relative --sort=modified --git-ignore -w "$w" "$@"
}

chpwd() { # Pull main on cd
  # Interactive only: the agent harness prepends `cd` to every command, so this
  # git pull would run constantly and can hang a big repo.
  [[ -o interactive ]] || return
  [[ ! -d .git ]] && return
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [ "$current_branch" = "main" ]; then
    echo "🕵️ Checking for new commmits 🔎"
    git pull origin main
  fi
}

# Load nvm properly
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


# alias brew for multi user
unalias brew 2>/dev/null
brewser=$(stat -f "%Su" $(which brew))
alias brew='sudo -Hu '$brewser' brew'

# Interactive only: non-interactive (agent/script) shells get plain ls, which
# avoids the ls_grid/eza path failing with exit 127 and forcing `command ls` retries.
ls() { if [[ -o interactive ]]; then ls_grid "$@"; else command ls "$@"; fi }
alias la="eza --icons=always --no-permissions --no-user --time-style=relative --git-ignore -la"
alias timer="/Users/Shared/dotfiles/scripts/timer.sh"
alias wheel="/Users/Shared/dotfiles/scripts/wheel.sh"
alias theme="/Users/Shared/dotfiles/scripts/theme.sh"
alias font="/Users/Shared/dotfiles/scripts/font.sh"

export DOTFILES_DEFAULT_FONT="Gyrotrope"
_ensure_font_defaults() {
  local override_file="/Users/Shared/dotfiles/wezterm/font-override"
  local favorites_file="/Users/Shared/dotfiles/wezterm/font-favorites"

  if [[ ! -s "$override_file" ]]; then
    printf '%s\n' "$DOTFILES_DEFAULT_FONT" > "$override_file"
  fi
  if [[ ! -f "$favorites_file" ]] || [[ ! -s "$favorites_file" ]]; then
    printf '%s\n' "$DOTFILES_DEFAULT_FONT" > "$favorites_file"
  elif ! awk -v d="$DOTFILES_DEFAULT_FONT" '$0==d { found=1 } END { exit(found ? 0 : 1) }' "$favorites_file"; then
    {
      printf '%s\n' "$DOTFILES_DEFAULT_FONT"
      cat "$favorites_file"
    } | awk 'NF && !seen[$0]++' > "${favorites_file}.tmp"
    mv "${favorites_file}.tmp" "$favorites_file"
  fi
}
_ensure_font_defaults

_ensure_theme_defaults() {
  local favorites_file="/Users/Shared/dotfiles/themes/favorites"
  local default_theme="catppuccin-mocha"

  if [[ ! -f "$favorites_file" ]] || [[ ! -s "$favorites_file" ]]; then
    printf '%s\n' "$default_theme" > "$favorites_file"
  elif ! awk -v d="$default_theme" '$0==d { found=1 } END { exit(found ? 0 : 1) }' "$favorites_file"; then
    {
      printf '%s\n' "$default_theme"
      cat "$favorites_file"
    } | awk 'NF && !seen[$0]++' > "${favorites_file}.tmp"
    mv "${favorites_file}.tmp" "$favorites_file"
  fi
}
_ensure_theme_defaults

# WezTerm background transparency (1=nearly transparent, 100=fully opaque)
opa() {
  local val="$1"
  if [[ -z "$val" ]] || ! [[ "$val" =~ ^[0-9]+$ ]] || (( val < 1 || val > 100 )); then
    echo "Usage: opa <1-100>"
    return 1
  fi
  echo "$val" > /Users/Shared/dotfiles/wezterm/opacity
  echo "Opacity set to ${val}%"
}

del-all() {
  local dir=$(pwd)
  echo "This will move all files in \033[1m${dir}\033[0m that contain a case-insensitive string in their filename to the Trash."
  echo ""
  read "pattern?Enter search string (or q to cancel): "
  [[ "$pattern" == "q" || -z "$pattern" ]] && echo "Cancelled." && return

  local matches=()
  for f in "$dir"/*; do
    [[ -f "$f" ]] && [[ "${f:t:l}" == *"${pattern:l}"* ]] && matches+=("$f")
  done

  if [[ ${#matches[@]} -eq 0 ]]; then
    echo "No files found matching \"$pattern\"."
    return
  fi

  echo ""
  echo "Found ${#matches[@]} file(s) matching \"$pattern\":"
  for f in "${matches[@]}"; do echo "  ${f:t}"; done
  echo ""
  read "confirm?Move these to Trash? (y/n): "
  [[ "$confirm" != "y" ]] && echo "Cancelled." && return

  local count=0
  for f in "${matches[@]}"; do
    mv "$f" ~/.Trash/ 2>/dev/null && ((count++))
  done
  echo "Moved $count file(s) to Trash."
}
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

alias pb="/Users/Shared/dotfiles/scripts/pb.sh"
alias new="/Users/Shared/dotfiles/scripts/new-desktop.sh"
alias nts="/Users/Shared/dotfiles/scripts/nts.sh"
alias slack="/Users/Shared/dotfiles/scripts/open-or-new-desktop.sh Slack"
alias wa="/Users/Shared/dotfiles/scripts/open-or-new-desktop.sh WhatsApp"
alias cal="/Users/Shared/dotfiles/scripts/open-or-new-desktop.sh Calendar"
alias deploy="/Users/Shared/dotfiles/scripts/deploy.sh"
# Worktree management
source "/Users/Shared/dotfiles/shell/git-helpers.zsh"
source "/Users/Shared/dotfiles/shell/worktree.zsh"
alias clean-worktrees="/Users/Shared/dotfiles/scripts/clean-worktrees.sh"
source "/Users/Shared/dotfiles/shell/wez-claude.zsh"
source "/Users/Shared/dotfiles/shell/ci-helpers.zsh"
alias flactoaif="/Users/Shared/dotfiles/scripts/flactoaif.sh"
alias stats="btop"

# Markdown to Word — converts .md to .docx via pandoc
md2doc() {
  local file="$1"
  if [[ -z "$file" ]]; then
    echo "Usage: md2doc <file.md>"
    return 1
  fi
  if [[ ! -f "$file" ]]; then
    echo "File not found: $file"
    return 1
  fi
  if [[ "$file" != *.md ]]; then
    echo "Not a markdown file: $file"
    return 1
  fi
  local output="${file%.md}.docx"
  if pandoc "$file" -o "$output" --from=markdown --to=docx; then
    echo "Created: $output"
  else
    echo "Conversion failed — is pandoc installed?"
    return 1
  fi
}

# Emoji picker (Ctrl+K) — fuzzy search via emoji-fzf + fzf
emoji-pick() {
  local emoji
  emoji=$(emoji-fzf preview \
    | fzf --preview 'emoji-fzf get --name {1}' --preview-window=up:1 \
    | awk '{ print $1 }' \
    | emoji-fzf get)
  if [[ -n "$emoji" ]]; then
    LBUFFER+="$emoji"
  fi
  zle reset-prompt
}
zle -N emoji-pick
bindkey '^K' emoji-pick

# Reload shell
clear() {
  command clear
  if [[ -n "$WEZTERM_PANE" ]] && command -v wezterm &>/dev/null; then
    local info
    info=$(wezterm cli list --format json 2>/dev/null)
    if [[ -n "$info" ]]; then
      local top_row left_col
      top_row=$(echo "$info" | python3 -c "import sys,json;[print(p['top_row']) for p in json.load(sys.stdin) if p['pane_id']==$WEZTERM_PANE]" 2>/dev/null)
      left_col=$(echo "$info" | python3 -c "import sys,json;[print(p['left_col']) for p in json.load(sys.stdin) if p['pane_id']==$WEZTERM_PANE]" 2>/dev/null)
      [[ "$top_row" == "0" && "$left_col" -gt 0 ]] && echo
    fi
  fi
  # Always succeed: the trailing [[ … ]] test above would otherwise leak a
  # non-zero status, breaking callers like `reload` (clear && exec zsh).
  return 0
}

tree() {
  local brief=0
  if [[ "$1" == "brief" ]]; then
    brief=1
    shift
  fi
  local treecmd=(command tree -F --noreport)
  (( brief )) && treecmd+=(--dirsfirst)
  "${treecmd[@]}" "$@" | python3 -c "
import sys
brief = $brief
raw = [l.rstrip('\n') for l in sys.stdin]
def dp(line):
    i = 0
    for ch in line:
        if ch in (' ', '\xa0', '|', '-', '\x60') or 0x2500 <= ord(ch) <= 0x257F:
            i += 1
        else: break
    return i // 4, i
def strip_node_modules(lines):
    out, skip_d = [], None
    for line in lines:
        if not line.strip():
            continue
        d, idx = dp(line)
        name = line[idx:].rstrip()
        if skip_d is not None:
            if d > skip_d:
                continue
            skip_d = None
        base = name.rstrip('/@')
        if base == 'node_modules':
            out.append(line)
            skip_d = d
            continue
        out.append(line)
    return out
raw = strip_node_modules(raw)
P = [(l, *dp(l)) for l in raw]
if not P: sys.exit()
if brief:
    def sibs(s, e, td):
        r, i = [], s
        while i < e:
            if P[i][1] < td: break
            if P[i][1] == td:
                j = i; i += 1
                while i < e and P[i][1] > td: i += 1
                r.append((j, i))
            else: i += 1
        return r
    def is_dir(idx):
        return P[idx][0][P[idx][2]:].rstrip().endswith('/')
    def trunc(s, e, pd):
        o, td = [], pd + 1
        ss = sibs(s, e, td)
        split = 0
        for idx, (a, b) in enumerate(ss):
            if not is_dir(a): break
            split = idx + 1
        else:
            if ss and is_dir(ss[-1][0]): split = len(ss)
        dirs, files = ss[:split], ss[split:]
        for a, b in dirs:
            o.append(P[a]); o += trunc(a+1, b, td)
        if len(files) > 2:
            h = len(files) - 2
            o.append(P[files[0][0]])
            ref = P[files[1][0]]
            o.append((ref[0][:ref[2]] + f'... ({h} more)', td, ref[2]))
            o.append(P[files[-1][0]])
        else:
            for a, b in files:
                o.append(P[a])
        return o
    te = len(P)
    while te > 1 and P[te-1][1] == 0: te -= 1
    P = [P[0]] + trunc(1, te, 0) + P[te:]
if not sys.stdout.isatty():
    for l, *_ in P: print(l)
else:
    C = ['\033[38;5;110m','\033[38;5;150m','\033[38;5;179m','\033[38;5;174m','\033[38;5;139m','\033[38;5;73m']
    R = '\033[0m'
    for l, d, *_ in P: print(f'{C[d%len(C)]}{l}{R}')
"
}

# Linear CLI defaults
export LINEAR_ISSUE_SORT="priority"

# Linear issue viewer (team key comes from the private overlay config)
li() {
  if [[ -z "$1" || -z "${LINEAR_TEAM_KEY:-}" ]]; then
    echo "Usage: li <issue-number> (requires LINEAR_TEAM_KEY)"
    return 1
  fi
  linear issue view "${LINEAR_TEAM_KEY}-$1" --no-pager
}

# Load secrets (API tokens, etc.)
[ -f /Users/Shared/dotfiles/shell/.secrets ] && source /Users/Shared/dotfiles/shell/.secrets

# --- Dotfiles live-reload --------------------------------------------------
# Shared configs are symlinks into /Users/Shared/dotfiles, so file edits are
# instant for both accounts. A running process still has the OLD config loaded
# until it re-reads. These helpers make that cheap; the git hooks +
# scripts/dotfiles-reload.sh push a nudge on every commit/pull.

# Heal a terminal left dirty by a TUI that exited abnormally (nvim killed,
# gh-dash panic). A crash skips the app's terminal teardown, leaving mouse
# tracking / bracketed paste / the alt screen on and stray bytes buffered in
# the input queue — which then corrupt the next program (a giant paste-like
# blob into gh-dash, or garbage fed to `exec zsh`).
_term_sanitize() {
  # Turn off modes the crashed TUI may have left enabled, restore the cursor.
  printf '\033[?1000l\033[?1002l\033[?1003l\033[?1006l\033[?2004l\033[?1049l\033[?25h'
  # Restore a known-good termios in a single atomic call.
  #
  # This deliberately does NOT drain the tty input queue any more. The old
  # version flipped the terminal to `-icanon -echo min 0 time 0` and ran a
  # non-blocking read loop; anything that interrupted that window left the tty
  # with echo off and stdin looking non-interactive, so the next commands
  # produced no output and TUIs refused to start. Un-flushed bytes from a
  # crashed TUI are the lesser evil: worst case a line of garbage at the next
  # prompt, cleared with Ctrl-C.
  stty sane 2>/dev/null
  return 0
}

# Reload this shell cleanly (fresh login shell, keeps cwd; avoids the
# non-idempotent re-source of evals/PATH that plain `source ~/.zshrc` causes).
# Sanitize first so a dirty terminal from a crashed TUI can't corrupt the
# freshly exec'd shell.
reload() { _term_sanitize; clear && exec zsh }

# Launch nvim with a control socket so dotfiles-reload can notify open editors.
# Sanitize ONLY on an abnormal exit (crash/kill → non-zero status). A clean :wq
# already restores the terminal, and re-running _term_sanitize against an
# already-clean tty races with it — the non-blocking input drain + raw-mode
# toggle intermittently swallows the next command's output and can leave stdin
# looking non-interactive (claude then drops into --print mode).
nvim() {
  local d="$HOME/.cache/nvim/sockets"
  command mkdir -p "$d"
  command nvim --listen "$d/nvim-$$-$RANDOM.sock" "$@"
  local rc=$?
  (( rc != 0 )) && _term_sanitize
  return $rc
}

# Nudge this shell when the shared dotfiles change (sentinel touched by the
# reload script). Compares the sentinel's mtime against what this shell last saw.
_DOTFILES_SENTINEL="/Users/Shared/dotfiles/.reload-sentinel"
_dotfiles_sentinel_mtime() { command stat -f %m "$_DOTFILES_SENTINEL" 2>/dev/null || echo 0; }
typeset -g _DOTFILES_NUDGE_SEEN="$(_dotfiles_sentinel_mtime)"
_dotfiles_nudge() {
  [[ -o interactive ]] || return
  local m; m="$(_dotfiles_sentinel_mtime)"
  if [[ "$m" != "$_DOTFILES_NUDGE_SEEN" ]]; then
    _DOTFILES_NUDGE_SEEN="$m"
    # No backticks/$(…) in this string: print -P re-expands it under PROMPT_SUBST,
    # which EXECUTES them. A literal `reload` here actually ran reload → exec zsh
    # inside prompt-expansion's capture subshell, leaving the new shell's stdout a
    # pipe — prompt still drew, but every command's output vanished.
    print -P '%F{yellow}⚠ dotfiles changed — run reload (shell) / restart or :source nvim%f'
  fi
}
precmd_functions+=(_dotfiles_nudge)
# ---------------------------------------------------------------------------

# Jump to Downloads
down() {
  cd "$HOME/Downloads"
}

# Render an image inline via wezterm imgcat. Defaults to half the terminal
# height; pass a trailing number to set the height percentage instead.
# Width auto-scales to preserve aspect ratio (imgcat keeps it by default).
# Usage: img <image-file> [more-images...] [percent]
#   img pic.jpg        # 50% of terminal height
#   img pic.jpg 100    # 100% of terminal height
img() {
  local pct=50
  local files=("$@")
  # A trailing numeric argument is the height percentage, not a file.
  if (( ${#files} )) && [[ "${files[-1]}" =~ '^[0-9]+$' ]]; then
    pct="${files[-1]}"
    files=("${files[1,-2]}")
  fi
  if (( ! ${#files} )); then
    echo "Usage: img <image-file> [more-images...] [percent]"
    return 1
  fi
  local f
  for f in "${files[@]}"; do
    wezterm imgcat --height "${pct}%" "$f"
  done
}


# Zoxide — smart cd with `z`. MUST stay the LAST line: zoxide warns and returns
# non-zero unless initialized last, and that noise leaks into non-interactive
# Bash output (spurious exit 127/143). Keep new additions ABOVE this block.
eval "$(zoxide init zsh --cmd cd)"

# bun completions
[ -s "/Users/alistair-personal/.bun/_bun" ] && source "/Users/alistair-personal/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

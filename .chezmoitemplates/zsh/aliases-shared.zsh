# =============================================================================
# Aliases — shared baseline (portable macOS + Linux).
# =============================================================================

# --- Core --------------------------------------------------------------------
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# --- Safety ------------------------------------------------------------------
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

# --- Listing -----------------------------------------------------------------
alias cls='clear && ls'
alias cll='clear && ls -la'
alias ll='ls -la'
alias la='ls -A'
if [[ "$(uname)" = Darwin ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi

# --- Git ---------------------------------------------------------------------
alias g='git'
alias gst='git status'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gl='git pull'
alias gp='git push'
alias gd='git diff'
alias gds='git diff --staged'
alias gcm='git commit -m'
alias ga='git add'
alias glog='git log --oneline -20'

# --- Chezmoi (gitops-style wrapper) ------------------------------------------
cm() {
  local sub="${1:-}"
  shift
  case "$sub" in
    add)    chezmoi add "$@" ;;
    commit) chezmoi git -- commit "$@" ;;
    push)   chezmoi git -- push "$@" ;;
    pull)   chezmoi git -- pull "$@" && chezmoi apply ;;
    git)    chezmoi git -- "$@" ;;
    *)      echo "Usage: cm add|commit|push|pull|git" >&2; return 1 ;;
  esac
}

# --- Misc --------------------------------------------------------------------
alias reload='exec zsh'
alias path='echo $path | tr " " "\n"'

# =============================================================================
# Aliases. Portable (macOS + Linux); safe for SSH/GCP sessions.
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

# --- Docker ------------------------------------------------------------------
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'

# --- Kubectl (GCP / k8s) -----------------------------------------------------
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kdp='kubectl describe pod'
alias kln='kubectl get nodes'

# --- Chezmoi (cm + short subcommands) ----------------------------------------
# Usage: cm st, cm ap, cm a ~/.zshrc, etc. No args -> chezmoi status.
cm() {
  local sub="${1:-}"
  shift
  case "$sub" in
    st)     chezmoi status "$@" ;;
    a)      chezmoi add "$@" ;;
    ap)     chezmoi apply "$@" ;;
    d)      chezmoi diff "$@" ;;
    ed)     chezmoi edit "$@" ;;
    re)     chezmoi re-add "$@" ;;
    '')     chezmoi status ;;
    *)      chezmoi "$sub" "$@" ;;
  esac
}

# --- Misc --------------------------------------------------------------------
alias reload='exec zsh'
alias path='echo $path | tr " " "\n"'

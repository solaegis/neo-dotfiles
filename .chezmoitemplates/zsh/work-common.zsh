# =============================================================================
# Work-context aliases (docker, kubectl). Loaded when work tooling is enabled.
# =============================================================================

# --- Docker ------------------------------------------------------------------
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'

# --- Kubectl -----------------------------------------------------------------
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kdp='kubectl describe pod'
alias kln='kubectl get nodes'

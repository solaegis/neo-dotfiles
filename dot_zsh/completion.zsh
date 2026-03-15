# =============================================================================
# Completion and fzf. Works with or without OMZ.
# =============================================================================

# --- Zsh completion (skip if OMZ already ran compinit) -----------------------
# Use compinit -D so .zcompdump is never created in $HOME.
if [[ -z "${ZSH:-}" ]]; then
  autoload -Uz compinit
  compinit -D
fi

# Menu selection, descriptions, case-insensitive
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# --- fzf (brew install fzf) --------------------------------------------------
if command -v fzf &>/dev/null; then
  # Use fd/ripgrep if available for faster listing
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
  [[ -f /usr/share/fzf/shell/key-bindings.zsh ]] && source /usr/share/fzf/shell/key-bindings.zsh
  [[ -f /usr/share/fzf/key-bindings.zsh ]]       && source /usr/share/fzf/key-bindings.zsh
  # Homebrew fzf on macOS
  [[ -f "$(brew --prefix 2>/dev/null)/opt/fzf/shell/key-bindings.zsh" ]] \
    && source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
  [[ -f "$(brew --prefix 2>/dev/null)/opt/fzf/shell/completion.zsh" ]] \
    && source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
fi

# =============================================================================
# Keybindings. Vi or emacs-style; history search.
# =============================================================================

# Emacs-style line editing (default)
bindkey -e

# History substring search (plugin binds if OMZ history-substring-search loaded)
# Fallback: same behavior with standard widgets
if zle -l history-substring-search-up 2>/dev/null; then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
else
  bindkey '^[[A' up-line-or-beginning-search
  bindkey '^[[B' down-line-or-beginning-search
fi

# Ctrl+Space: accept autosuggestion (when zsh-autosuggestions is loaded)
bindkey '^ ' forward-char

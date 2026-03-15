# =============================================================================
# Oh My Zsh + Powerlevel10k. Loads only if OMZ is installed.
# Optional: to add zinit, source it before this file in .zshrc and use it
# for extra/fast plugins; OMZ remains the main theme + plugin manager here.
# =============================================================================

ZSH="${ZSH:-$HOME/.oh-my-zsh}"
[[ ! -d "$ZSH" ]] && return

# Don't create .zcompdump in $HOME; send to cache (or /dev/null to disable dump).
export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  docker
  kubectl
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
)

source "$ZSH/oh-my-zsh.sh"

# Load p10k config if present (run `p10k configure` to create)
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

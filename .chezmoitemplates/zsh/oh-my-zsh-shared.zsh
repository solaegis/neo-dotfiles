# =============================================================================
# Oh My Zsh + Powerlevel10k. Loads only if OMZ is installed.
# =============================================================================

ZSH="${ZSH:-$HOME/.oh-my-zsh}"
[[ ! -d "$ZSH" ]] && return

export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
{{- $ctx := .context | default "personal" -}}
{{- $workTooling := or (hasPrefix $ctx "work-") (gt ((.enabledWorkProfiles | default list) | len) 0) -}}
{{- if $workTooling }}
  docker
  kubectl
{{- end }}
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
)

source "$ZSH/oh-my-zsh.sh"

[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

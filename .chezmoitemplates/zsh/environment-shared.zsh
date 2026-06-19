# =============================================================================
# Environment: options, history, and core vars. Portable (macOS + Linux).
# =============================================================================

# --- Options -----------------------------------------------------------------
setopt AUTO_CD              # `foo` runs cd foo if foo is a dir
setopt EXTENDED_GLOB        # # ~ ^ glob operators
setopt NO_BEEP
setopt CORRECT              # Suggest corrections for commands
setopt INTERACTIVE_COMMENTS # Allow # comments in interactive shell

# --- History -----------------------------------------------------------------
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY         # Share history across sessions
setopt HIST_IGNORE_ALL_DUPS  # Dedupe by removing older duplicate
setopt HIST_IGNORE_SPACE     # Don't record lines starting with space
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY           # Show expanded history line before running

# --- Editor / pager ----------------------------------------------------------
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS="-R"

# --- Path (append custom bins if present) ------------------------------------
[[ -d "$HOME/.local/bin" ]] && path=( "$HOME/.local/bin" $path )

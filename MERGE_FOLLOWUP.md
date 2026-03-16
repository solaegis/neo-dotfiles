# Atreides-to-Neo Merge Follow-up (Tactical)

Items for **separate work** after the minimalist merge. Not included in the initial merge.

---

## 1. Modern aliases + git aliases + macOS block

**Source**: atreides `~/.config/zsh/aliases.zsh`, `modern-aliases.zsh`

**Target**: `dot_zsh/aliases.zsh`

| Category | Aliases / Commands |
|----------|--------------------|
| **Modern tools (eza/bat/btop)** | Conditionals: if eza exists → `ls`/`ll`/`la`; if bat exists → `cat`; if btop exists → `top` |
| **Git extended** | gca, gap, gup, gfa, gph, gri, gwip, gunwip, gsta, gstp, gstl |
| **macOS** | flushdns, showfiles, hidefiles, battery, `path` alias |

---

## 2. Utility functions

**Source**: atreides `~/.config/zsh/functions.zsh`

**Target**: `dot_zsh/functions.zsh`

| Function | Purpose |
|----------|---------|
| duh | Human-readable disk usage |
| lss | Enhanced ls variant |
| netinfo | Network info summary |
| portcheck | Check if port is in use |
| json | Pretty-print JSON |
| b64 | Base64 encode/decode |
| genpass | Generate random password |
| weather | Weather via CLI |
| backup | Backup helper |
| gci | Git clone + cd |
| dclean | Docker cleanup |
| dshell | Docker shell into container |
| pskill | Kill process by name |
| projinit | Project scaffold |
| gbclean | Git branch cleanup |
| gwt | Git worktree helper |

---

## 3. Expand dot_gitconfig

**Source**: atreides `~/.gitconfig`

**Target**: `dot_gitconfig`

| Section | Additions |
|---------|-----------|
| [core] | editor, excludesfile, autocrlf, quotepath (if missing) |
| [push] | followTags = true |
| [merge] | Conflict style, tool |
| [diff] | Tool, algorithm |
| [rebase] | Auto stash, autosquash |
| [fetch] | Prune, pruneTags |
| [gc] | Auto, autoPackLimit |
| [color] | ui = auto; diff, branch, status, interactive |

---

## Notes

- Apply zsh best practices (from MERGE_PLAN) when adding aliases/functions.
- Prefer `[[ ]]` conditionals and `command -v` checks.
- Keep aliases and functions portable (macOS + Linux) where possible.

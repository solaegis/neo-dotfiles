# Dotfiles Merge Plan: atreides → neo-dotfiles

## Context

**Goal:** Harvest the best of the current live dotfiles on `atreides` into `neo-dotfiles`, without polluting neo's clean architecture.

**Rule:** When there is a conflict, **neo-dotfiles wins** — it represents the target pattern. atreides content is harvested only where neo is incomplete or absent.

---

## Inventory: What Exists Where

### atreides live dotfiles (`~`)
- **Plugin manager:** Zinit (zdharma-continuum/zinit)
- **Prompt:** Powerlevel10k (direct sourcing via Homebrew, no OMZ)
- **Zsh config dir:** `~/.config/zsh/` (not `~/.zsh/`)
- **Files present:**
  - `~/.zshenv` — Homebrew, PATH, EDITOR fallback chain, GOPATH, Cargo, **zerobrew** setup, PKG_CONFIG_PATH
  - `~/.zprofile` — path additions, AWS_DEFAULT_PROFILE, OrbStack, node@20, openjdk@11, GCP SDK
  - `~/.zshrc` — monolithic, sources ~/.config/zsh/* modules, Zinit, Powerlevel10k
  - `~/.zshrc.local` — stub (only echo, no real content)
  - `~/.p10k.zsh` — full customized Powerlevel10k config (segments, colors, icons)
  - `~/.config/zsh/aliases.zsh` — core aliases + atreides-specific
  - `~/.config/zsh/functions.zsh` — extensive (chezmoi, git, docker, terraform, SSH agent, utilities)
  - `~/.config/zsh/modern-aliases.zsh` — exhaustive modern-tool aliases (eza, bat, btop, procs, etc.)
  - `~/.config/zsh/zinit-setup.zsh` — Zinit plugin loading + syntax highlight config
  - `~/.config/zsh/completion-optimizer.zsh` — compile .zsh → .zwc, weekly stale cache cleanup
  - `~/.config/zsh/history-maintenance.zsh` — prune history on exit at 90% capacity
  - `~/.gitconfig` — global git config; hub alias; includeIf for ~/git/, ~/git-work/, ~/git-lv/, ~/git-dnlc/, ~/NAS/git-dnlc/
  - `~/.gitconfig-personal` — gmail + id_rsa
  - `~/.gitconfig-work` — acxiom email + id_rsa_work
  - `~/.gitconfig-lv` — gmail + id_rsa_lv + `url insteadOf` rewrite
  - `~/.gitconfig-dnlc` — dadandlad.co email + id_rsa_dnlc
  - `~/.gitignore_global` — comprehensive (macOS, Windows, Linux, editors, node_modules, .env, etc.)
  - `~/.Brewfile` — ~30 packages (bat, eza, ripgrep, btop, direnv, fzf, zoxide, gh, glow, uv, yt-dlp, fonts)
  - `~/.ssh/config` — OrbStack Include, `desktop` (Tailscale), github.com (id_rsa), github.com-lv (id_rsa_lv), github.com-work (id_rsa_work), homelab hosts (homepage, pve-prod-1, pve-prod-2)
  - `~/Library/Application Support/Cursor/User/settings.json` — rich settings (FiraCode Nerd Font, Warp terminal, Gemini Code Assist, git autofetch, many more)

### neo-dotfiles (`/Users/lvavasour/git/neo-dotfiles`)
- **Plugin manager:** Oh My Zsh (OMZ) with powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting
- **Prompt:** Powerlevel10k via OMZ theme
- **Zsh config dir:** `~/.zsh/` (chezmoi source: `dot_zsh/`)
- **Files present:**
  - `dot_zshrc` — minimal, sources `~/.zsh/*.zsh` modules only
  - `dot_zprofile` — Homebrew shellenv, SSH agent auto-add (all `~/.ssh/id_*` keys, Apple keychain)
  - `dot_zsh/environment.zsh` — options, history, EDITOR/PAGER, `~/.local/bin` path
  - `dot_zsh/oh-my-zsh.zsh` — OMZ + p10k theme + 7 plugins
  - `dot_zsh/aliases.zsh` — clean minimal aliases + `cm()` chezmoi dispatcher
  - `dot_zsh/completion.zsh` — compinit, zstyle, fzf (with fd fallback)
  - `dot_zsh/keybindings.zsh` — bindkey -e, history-substring-search, ctrl+space autosuggest
  - `dot_zsh/functions.zsh` — minimal (mkcd, serve, extract)
  - `dot_gitconfig` — global git config; [include] for ~/.config/git/github-urls.config
  - `dot_gitconfig-acxiom` — acxiom email + `url insteadOf` rewrite
  - `dot_gitconfig-dadandlad` — dadandlad.co email + rewrite
  - `dot_gitconfig-nuvent` — nuvent.io email + rewrite
  - `dot_gitconfig-solaegis` — solaegis.com email + rewrite
  - `dot_config/git/github-urls.config` — per-org URL rewrites (acxiom, solaegis, dadandlad, nuvent)
  - `dot_config/Cursor/User/settings.json` — 3 settings (commandCenter, font, panel location)
  - `Brewfile.tmpl` — data-driven from .chezmoidata.toml (currently minimal: chezmoi, zsh, git, fzf, age, mas + Meslo font)
  - `.chezmoidata.toml` — Brew formulae/casks/MAS apps per OS + per-host
  - `.chezmoi.toml` — age encryption configured
  - `.chezmoiignore.tmpl` — OS-conditional ignores (Cursor/Library)
  - `run_once_brew_bundle.sh` — installs Brewfile once
  - `run_once_git_dirs.sh` — creates ~/git/{acxiom,solaegis,dadandlad,nuvent}
  - `run_once_iterm_status_bar.py` — iTerm2 setup
  - `run_once_mas_install.sh` — MAS app install
  - `run_once_ssh_permissions.sh` — SSH file permissions
  - `private_dot_ssh/config` — **EMPTY** (needs population)
  - `mas-ids.txt.tmpl` — data-driven from .chezmoidata.toml

---

## Merge Decisions by File

### 1. `dot_zprofile`
**Status:** neo wins — clean and correct.  
**Harvest from atreides:**
- `AWS_DEFAULT_PROFILE=lburg_acxiom` → add to environment.zsh or as a template with host guard (`[[ "$(hostname)" == atreides* ]]`) in `.chezmoidata.toml`
- OrbStack `source ~/.orbstack/shell/init.zsh` → add conditionally (`[[ -f ~/.orbstack/shell/init.zsh ]]`)
- node@20 / openjdk@11 PATH additions → add as conditional blocks (check dir existence, already that pattern)
- GCP SDK `path.zsh.inc` → add conditionally
- No zerobrew — zerobrew is atreides-specific and experimental; **skip**

---

### 2. `dot_zsh/environment.zsh`
**Status:** neo wins — clean.  
**Harvest from atreides `~/.zshenv`:**
- GOPATH/GOBIN export → add to environment.zsh
- EDITOR fallback chain (`code` → `cursor` → `vim`) → replace neo's static `${EDITOR:-vim}`
- Cargo env sourcing (`~/.cargo/env`) → add with existence check
- `~/.cargo/bin` on PATH → add
- `~/go/bin` on PATH → add
- **Skip:** zerobrew block (atreides-specific experiment)
- **Skip:** ZEROBREW_* vars
- **Skip:** duplicate `.cargo/env` sourcing (atreides has it twice — bug)

---

### 3. `dot_zshrc`
**Status:** neo wins — minimal and correct.  
**No harvest needed.** The atreides `.zshrc` is monolithic for a reason (Zinit, different config dir); neo's approach is cleaner.  
**Consider:** adding sourcing of `~/.zshrc.local` at end for machine-local overrides (atreides had this pattern; useful for multi-machine).

---

### 4. `dot_zsh/oh-my-zsh.zsh`
**Status:** neo wins.  
**No harvest needed.** atreides uses Zinit, not OMZ.

---

### 5. `dot_zsh/aliases.zsh`
**Status:** neo wins for structure. Harvest selectively from atreides.  
**Harvest from atreides `~/.config/zsh/aliases.zsh` and `modern-aliases.zsh`:**
- Modern tool replacements (eza, bat, btop) — port the conditional `if command -v eza` blocks
- `alias reload='exec zsh'` (neo has `reload='exec zsh'` — same, already there)
- Directory shortcuts with zoxide: `alias cd='z'`, `alias j='z'` (if zoxide available)
- Git alias expansion: many from modern-aliases.zsh are worth adding (gca, gap, gup, gfa, gph, gri, gwip, gunwip, gsta/gstp/gstl)
- flushdns, showfiles/hidefiles, battery (macOS only block)
- `alias path='echo $path | tr " " "\n"'` — cleaner than current
- **Skip:** atreides aliases that conflict with neo's `cm()` function
- **Skip:** zinit-specific aliases
- **Skip:** `alias git="hub"` — atreides uses hub; neo doesn't, skip
- **Skip:** `alias claude=...` hardcoded path — too machine-specific
- **Skip:** chezmoi duplicates (atreides has both `cz` and `czst`/`czdf` etc.; neo has clean `cm()`)

---

### 6. `dot_zsh/functions.zsh`
**Status:** neo has minimal 3 functions. Harvest from atreides.  
**Harvest from atreides `~/.config/zsh/functions.zsh`:**
- `mkcd()` — same in both, keep neo's
- `extract()` — neo has it, keep neo's
- `serve()` — neo has it (via python3 http.server), keep neo's
- `duh()` — disk usage with dust fallback, add
- `lss()` — list files by size with eza fallback, add
- `brewup()` / `brewclean()` — useful, add (strip chezmoi-specific bits)
- `netinfo()` — useful, add
- `portcheck()` — useful, add
- `json()` — useful, add
- `b64()` — useful, add
- `genpass()` — useful, add
- `gwt()` — git worktree wrapper, add
- `gcm()` — enhanced commit with validation, add (rename to avoid clash with neo alias)
- `weather()` — fun, add
- `backup()` — useful, add
- SSH agent functions (`start_ssh_agent`, `load_ssh_keys`, `ssh_status`, etc.) — **evaluate**: neo handles SSH in dot_zprofile cleanly. These are useful interactively but don't override dot_zprofile's approach. Add as optional helpers.
- chezmoi functions (czstatus, czdiff, etc.) — **skip**: neo uses the `cm()` dispatcher pattern; avoid duplication
- `tf()` terraform safety wrapper — **consider**: useful guard against accidental destroy; add if terraform is in Brewfile
- `gci()` interactive conventional commit — add
- Docker functions (`dclean`, `dshell`) — add
- `pskill()` — add
- `projinit()` — add
- `gbclean()` — add
- `gaa()`, `gst()`, `gpush()`, `gpull()`, `gcm()` git wrappers — **skip**: already covered by aliases in neo

---

### 7. `dot_zsh/completion.zsh`
**Status:** neo wins.  
**Harvest from atreides:** Nothing critical. Atreides' completion is more complex (daily recompile, Homebrew FPATH) but neo's approach is cleaner.  
**Consider:** Adding `FPATH` for Homebrew completions (`$(brew --prefix)/share/zsh-completions`) as a conditional block.

---

### 8. `dot_zsh/keybindings.zsh`
**Status:** neo wins — already complete.  
**No harvest needed.**

---

### 9. `dot_gitconfig`
**Status:** neo wins for structure ([include] + URL rewrite model is better).  
**Harvest from atreides `~/.gitconfig`:**
- Additional aliases not in neo: `cam`, `co`, `rb`, `rbi`, `lp`, `search`, `ff`, `d`, `dc`, `uc`, `startover`, `sl`, `sp`, `ss`, `find`, `last`, `amend`, `recent`, `pf`
- `[core]` additions: `editor = cursor --wait`, `autocrlf = input`, `precomposeunicode = true`, `quotepath = false`, `preloadindex = true`, `fscache = true`, `excludesfile = ~/.gitignore_global`
- `[push]`: `followTags = true` (neo missing)
- `[merge]`: `tool = cursor`, `conflictstyle = diff3`; mergetool/difftool cursor entries
- `[diff]`: `tool = cursor`; difftool cursor entry
- `[rebase]`: `autoStash = true`
- `[fetch]`: `prune = true`, `fsckobjects = true`
- `[color]` sections — add full color config
- `[transfer]` / `[receive]` fsck options
- `[gc]` auto = 256
- `includeIf` entries: atreides uses `~/git/` → personal; neo creates `~/git/acxiom/`, `~/git/solaegis/` etc. The neo model (subdirectories per org) is the **new pattern**. Update includeIf blocks in neo to match:
  ```
  [includeIf "gitdir:~/git/acxiom/"]  path = ~/.gitconfig-acxiom
  [includeIf "gitdir:~/git/solaegis/"] path = ~/.gitconfig-solaegis
  [includeIf "gitdir:~/git/dadandlad/"] path = ~/.gitconfig-dadandlad
  [includeIf "gitdir:~/git/nuvent/"]   path = ~/.gitconfig-nuvent
  [includeIf "gitdir:~/git-work/"]     path = ~/.gitconfig-acxiom   # atreides legacy; add for compat
  ```

---

### 10. Per-identity gitconfigs
**Status:** neo wins — model already correct with acxiom/solaegis/dadandlad/nuvent.  
**atreides had:** personal (gmail+id_rsa), work (acxiom+id_rsa_work), lv (gmail+id_rsa_lv), dnlc (dadandlad+id_rsa_dnlc)  
**Mapping to neo identities:**
- atreides `personal` → neo `solaegis` (gmail, id_rsa) ✓ already in neo
- atreides `work` → neo `acxiom` (acxiom email) ✓ already in neo
- atreides `lv` → no direct neo equivalent; **add `dot_gitconfig-lv`** for the lv key+identity (used in `~/git-lv/`)
- atreides `dnlc` → neo `dadandlad` ✓ already in neo (note: email in neo is `lewis.vavasour@dadandlad.co`; atreides has `dadandlad.co@gmail.com` — verify which is correct)

---

### 11. `dot_config/git/github-urls.config`
**Status:** neo wins — already correct.  
**No harvest needed.** atreides used per-identity `url insteadOf` in individual gitconfig files; neo centralizes in github-urls.config which is cleaner.

---

### 12. `dot_gitignore_global` (new file to add to neo)
**Status:** **Missing from neo** — add from atreides.  
**Action:** Create `dot_gitignore_global` in neo from atreides `~/.gitignore_global`.  
Confirm `dot_gitconfig` references it via `excludesfile = ~/.gitignore_global`.

---

### 13. `private_dot_ssh/config`
**Status:** **Empty in neo** — populate from atreides.  
**Harvest from atreides `~/.ssh/config`:**
- Keep `Include ~/.orbstack/ssh/config` (conditionally — when orbstack is present)
- `Host desktop` (Tailscale IP 100.88.223.50) — **host-specific** (atreides); include with hostname guard or note to customize
- GitHub multi-identity hosts: `github.com`, `github.com-lv`, `github.com-work` → update to neo identity names: `github.com-solaegis`/`github.com-acxiom`/`github.com-nuvent`/`github.com-dadandlad`
- Homelab hosts (`homepage`, `pve-prod-1`, `pve-prod-2`) — keep but note host-specific
- `Host *` global settings — keep (AddKeysToAgent, UseKeychain, IdentitiesOnly, ServerAlive, HashKnownHosts)
- **Note:** neo's `dot_zprofile` auto-adds all `~/.ssh/id_*` keys; IdentityFile entries per GitHub host must use neo key naming convention (id_ed25519_acxiom, id_ed25519_solaegis, etc. — to be confirmed)

---

### 14. `dot_config/Cursor/User/settings.json`
**Status:** neo has minimal 3 settings; atreides has full settings.  
**Harvest from atreides `~/Library/Application Support/Cursor/User/settings.json`:**
- `terminal.integrated.fontFamily` → change to `"MesloLGS NF, FiraCode Nerd Font Mono, Menlo, monospace"` (neo has Meslo; atreides has FiraCode — use both with Meslo first to match neo's Meslo NF font)
- `terminal.external.osxExec: "Warp.app"` — add if Warp is used on neo
- `terminal.integrated.copyOnSelection: true` — add
- `terminal.integrated.defaultProfile.osx: "zsh"` — add
- `terminal.integrated.profiles.osx` with brew zsh path — add
- `git.autofetch: true` — add
- `workbench.editor.enablePreview: false` — add
- `go.toolsManagement.autoUpdate: true` — add
- Gemini Code Assist settings — **skip** or make optional (tied to specific GCP project)
- `pieces.OS.launchOnStartup` — **skip** (Pieces is app-specific)
- `window.commandCenter` — neo has `true` (boolean); atreides has `1` (number) — use `true`
- `[dockercompose]` / `[github-actions-workflow]` formatter defaults — add

---

### 15. `Brewfile.tmpl` / `.chezmoidata.toml`
**Status:** neo wins for structure (data-driven). Harvest package list from atreides.  
**Add to `[brew.mac]` formulae in `.chezmoidata.toml`:**
- `bat`, `eza`, `ripgrep`, `direnv`, `jq`, `htop`, `tree`, `wget`, `curl`, `vim`
- `gh`, `glow`, `zoxide`, `uv`
- `yt-dlp` (personal preference — can go under `[brew.hosts.neo]` if atreides-specific)
- `btop` (if preferred over htop), `procs`, `dust` (modern tool alternatives)
- `delta` (git-delta — referenced in atreides .zshrc as GIT_PAGER)
- `hub` — **skip** (atreides used it; neo doesn't, OMZ has git plugin)
- `orbstack` → **skip** (managed separately as a cask; add only if intentional)
- `google-cloud-sdk` → cask — consider adding
- `rustup` → add (atreides has it in PATH)
- `node@20`, `openjdk@11` → optional, add with comment

**Add to `[brew.mac]` casks:**
- `font-hack-nerd-font`, `font-fira-code-nerd-font` (atreides has these; complement neo's Meslo)
- `warp` if Warp is intentional as terminal
- `google-cloud-sdk` 

**Host-specific (`[brew.hosts.atreides]`):**
- `yt-dlp` if only wanted on atreides  
- `antigravity` path suggests a non-brew install — skip or document separately

---

### 16. `run_once_*` scripts
**Status:** neo wins — already complete.  
**Consider adding:**
- `run_once_configure_git_delta.sh` — set up `~/.gitconfig` pager = delta if delta installed
- `run_onchange_configure_zsh_completions.sh` — create `~/.cache/zsh/` dir
- `run_once_install_omz.sh` — bootstrap OMZ + plugins if not present (currently just documented in dot_zprofile comments)

---

### 17. `dot_p10k.zsh` (new file to add to neo)
**Status:** **Missing from neo** — neo references `~/.p10k.zsh` but doesn't ship one.  
**Action:** Add atreides' `~/.p10k.zsh` as `dot_p10k.zsh` in neo.  
The atreides config has well-customized segments and colors — this is worth keeping.

---

### 18. Completion optimizer and history maintenance
**Status:** **Missing from neo.**  
**Evaluate:**
- `completion-optimizer.zsh` — compiles .zsh → .zwc for faster startup. Useful but adds complexity. **Recommend: port the one-liner auto-compile check** into neo's `dot_zsh/completion.zsh` rather than a whole extra file.
- `history-maintenance.zsh` — prune history on exit at 90% capacity. **Recommend: port** as a small addition to `dot_zsh/environment.zsh`.

---

## Summary: Actions for Merge Session

| # | Action | Target File in neo | Source |
|---|--------|-------------------|--------|
| 1 | Add GOPATH, Cargo, EDITOR fallback chain | `dot_zsh/environment.zsh` | atreides `.zshenv` |
| 2 | Add OrbStack, GCP SDK, node/jdk PATH, AWS profile | `dot_zprofile` | atreides `.zprofile` |
| 3 | Add zshrc.local sourcing at end | `dot_zshrc` | atreides pattern |
| 4 | Add modern tool aliases (eza/bat/btop conditional blocks) | `dot_zsh/aliases.zsh` | atreides `modern-aliases.zsh` |
| 5 | Add additional git aliases from atreides | `dot_zsh/aliases.zsh` | atreides `modern-aliases.zsh` |
| 6 | Add macOS-specific aliases block | `dot_zsh/aliases.zsh` | atreides `modern-aliases.zsh` |
| 7 | Add utility functions: duh, lss, netinfo, portcheck, json, b64, genpass, weather, backup, tf, gci, dclean, dshell, pskill, projinit, gbclean, gwt | `dot_zsh/functions.zsh` | atreides `functions.zsh` |
| 8 | Add SSH agent helper functions | `dot_zsh/functions.zsh` | atreides `functions.zsh` |
| 9 | Port history prune hook | `dot_zsh/environment.zsh` | atreides `history-maintenance.zsh` |
| 10 | Port one-liner .zwc compile check | `dot_zsh/completion.zsh` | atreides `completion-optimizer.zsh` |
| 11 | Add Homebrew FPATH for completions | `dot_zsh/completion.zsh` | atreides `.zshrc` |
| 12 | Expand aliases, color, merge/diff/rebase/fetch/gc sections | `dot_gitconfig` | atreides `.gitconfig` |
| 13 | Add includeIf blocks (acxiom/solaegis/dadandlad/nuvent/git-work) | `dot_gitconfig` | atreides `.gitconfig` + neo model |
| 14 | Add `dot_gitconfig-lv` for lv identity | new file | atreides `.gitconfig-lv` |
| 15 | Verify dadandlad email (dadandlad.co@gmail.com vs lewis.vavasour@dadandlad.co) | `dot_gitconfig-dadandlad` | both |
| 16 | Create `dot_gitignore_global` | new file | atreides `.gitignore_global` |
| 17 | Populate `private_dot_ssh/config` | `private_dot_ssh/config` | atreides `.ssh/config` |
| 18 | Expand Cursor settings.json | `dot_config/Cursor/User/settings.json` | atreides Cursor settings |
| 19 | Expand brew package list in `.chezmoidata.toml` | `.chezmoidata.toml` | atreides `.Brewfile` |
| 20 | Add casks to `.chezmoidata.toml` | `.chezmoidata.toml` | atreides `.Brewfile` |
| 21 | Add `dot_p10k.zsh` | new file | atreides `~/.p10k.zsh` |
| 22 | Add `run_once_install_omz.sh` bootstrap script | new file | atreides docs/manual |
| 23 | Add host-specific .chezmoidata section for atreides | `.chezmoidata.toml` | atreides patterns |

---

## Files to Explicitly NOT Merge (atreides-specific / deprecated)

| File | Reason |
|------|--------|
| `~/.config/zsh/zinit-setup.zsh` | Zinit is the old plugin manager; neo uses OMZ |
| `~/.config/zsh/completion-optimizer.zsh` | Port only the one-liner; skip full file |
| `~/.config/zsh/history-maintenance.zsh` | Port hook only; skip full file |
| `zerobrew` variables and PATH blocks | Experimental atreides-only tool |
| `alias git="hub"` | hub wrapper not used in neo |
| `alias claude=...` hardcoded path | Too machine-specific |
| `alias cz*`/`czstatus` etc. chezmoi aliases | neo uses `cm()` dispatcher pattern |
| `AWS_DEFAULT_PROFILE=lburg_acxiom` as hard value | Should be host-template or local override |
| `CODE_ASSIST_ENDPOINT` (CLIProxy) in `.zshrc` | atreides-specific Gemini proxy hack |
| Gemini Code Assist GCP project ID in Cursor settings | atreides GCP project; not portable |
| `git@github.com-lv: insteadOf` in gitconfig-lv | Rework to match neo URL rewrite model |

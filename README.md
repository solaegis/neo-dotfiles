# Dotfiles (chezmoi)

[![Managed by chezmoi](https://img.shields.io/badge/managed_by-chezmoi-00b0b9)](https://www.chezmoi.io/)

Managed by [chezmoi](https://www.chezmoi.io/). Multi-context layout: **shared baseline → personal/work context → optional work profiles**. Includes zsh (Oh My Zsh, Powerlevel10k, fzf), Cursor settings, SSH/git identities, age-encrypted keys, Homebrew (Brewfile), and Mac App Store apps (mas).

## Architecture

```
shared baseline (.chezmoidata.toml brew.shared, .chezmoitemplates/)
    → context (personal | work-<profile>)     [~/.config/chezmoi/chezmoi.toml]
    → enabledWorkProfiles (consultant mode)   [optional, local]
    → hostname overrides (brew.hosts.neo, …)
    → rendered targets (~/.zshrc, ~/.gitconfig, Brewfile, …)
```

| Variable | Set in | Purpose |
|----------|--------|---------|
| `context` | `~/.config/chezmoi/chezmoi.toml` `[data]` | `personal` or `work-<slug>` |
| `enabledWorkProfiles` | local `[data]` | Multi-client git/SSH on consultant machines |
| `profiles.*` | `.chezmoidata/profiles.toml` | Git email, SSH key slug, git dir per org |

### Per-host context (examples)

| Host | `context` | `enabledWorkProfiles` | Notes |
|------|-----------|------------------------|-------|
| `neo` | `personal` | `[]` | Strict personal; work keys ignored |
| consultant Mac | `personal` | `["solaegis","acxiom","nuvent","dadandlad"]` | Multi-identity `~/git/<org>` |
| work laptop | `work-acme` | `["acme"]` | Work-only packages and keys |

## First-time setup

1. **Install chezmoi**: `brew install chezmoi age`
2. **Clone** to `~/git/solaegis/neo-dotfiles`
3. **Configure** `~/.config/chezmoi/chezmoi.toml` (do not commit):

```toml
sourceDir = "~/git/solaegis/neo-dotfiles"
encryption = "age"

persistentState = "~/.local/state/chezmoi/personal/chezmoi.boltdb"
cacheDir = "~/.cache/chezmoi/personal"

[data]
  context = "personal"
  enabledWorkProfiles = []

[age]
  identity = "~/.config/chezmoi/age.key"
  recipient = "age1..."  # your public key
```

4. **Apply**: `chezmoi apply`

## What’s managed

| Source | Target |
|--------|--------|
| `dot_zshrc.tmpl` + `.chezmoitemplates/zsh/*` | `~/.zshrc`, shared shell modules |
| `dot_zprofile.tmpl` | `~/.zprofile` (brew env, context-aware ssh-agent) |
| `dot_zsh/completion.zsh`, `functions.zsh`, `keybindings.zsh` | `~/.zsh/*.zsh` |
| `dot_gitconfig.tmpl` | `~/.gitconfig` (includeIf for enabled profiles) |
| `dot_gitconfig-<profile>` | `~/.gitconfig-<profile>` (when profile allowed) |
| `dot_config/git/github-urls.config.tmpl` | `~/.config/git/github-urls.config` |
| `private_dot_ssh/private_config.tmpl` | `~/.ssh/config` |
| `private_dot_ssh/encrypted_private_id_*` | `~/.ssh/id_*` (age-encrypted, profile-gated) |
| `.chezmoidata.toml` + `.chezmoidata/*` | brew/mas/profiles/packages data |
| `Brewfile.tmpl` | `~/Brewfile` → `run_onchange_brew-bundle.sh.tmpl` |
| `mas-ids.txt.tmpl` | `~/mas-ids.txt` → `run_once_mas_install.sh` |
| `Library/private_Preferences/eu.exelban.Stats.plist` | Stats menu bar prefs (personal) |
| `Library/Application Support/Cursor/...` | Cursor settings (macOS) |

## Homebrew and Mac App Store

**Layer precedence:** `brew.shared` → OS/linux → `brew.personal` or `brew.work` → `brew.profiles.<slug>` → `enabledWorkProfiles` → `brew.hosts.<hostname>`.

Same pattern for `mas.shared`, `mas.personal`, `mas.hosts.<hostname>`.

**Add a package:**

1. Edit the correct layer in [`.chezmoidata.toml`](.chezmoidata.toml)
2. Register config in [`.chezmoidata/packages.toml`](.chezmoidata/packages.toml) if the tool has dotfiles
3. `chezmoi apply && chezmoi git commit -m "add <pkg>"`

**Audit installed vs managed:**

```bash
brew bundle dump --describe --force --file=/tmp/audit.Brewfile
chezmoi cat ~/Brewfile > /tmp/managed.Brewfile
diff /tmp/audit.Brewfile /tmp/managed.Brewfile
brew bundle check --file="$HOME/Brewfile"
```

## SSH, git, and encryption

- **Strict personal** (`enabledWorkProfiles = []`): only `neo` + `atreides` SSH keys; work keys are in repo but **ignored** via `.chezmoiignore.tmpl`
- **Consultant mode**: set `enabledWorkProfiles = ["solaegis", "acxiom", …]`; `includeIf` loads `~/.gitconfig-<profile>` under `~/git/<org>/`
- **Age encryption**: `age-keygen -o ~/.config/chezmoi/age.key`; add keys with `chezmoi add --encrypt ~/.ssh/id_ed25519_<profile>`

## Add a new work profile

1. Register in [`.chezmoidata/profiles.toml`](.chezmoidata/profiles.toml):

```toml
[profiles.omega]
git_name = "Your Name"
email = "you@omega.corp"
git_dir = "omega"
ssh_key = "omega"
github_host_alias = "github.com-omega"
github_orgs = ["omega-corp"]
```

2. Add packages in `.chezmoidata.toml` under `[brew.profiles.omega]` if needed
3. Add `dot_gitconfig-omega` with profile-specific git config
4. `chezmoi add --encrypt ~/.ssh/id_ed25519_omega`
5. On the work machine, set local config:

```toml
[data]
  context = "work-omega"
  enabledWorkProfiles = ["omega"]
persistentState = "~/.local/state/chezmoi/work-omega/chezmoi.boltdb"
cacheDir = "~/.cache/chezmoi/work-omega"
```

6. `chezmoi apply && chezmoi ignored | rg omega` — verify only omega artifacts apply

## Useful commands

```bash
chezmoi data | jq '{context, enabledWorkProfiles, hostname: .chezmoi.hostname}'
chezmoi ignored | rg 'gitconfig|id_ed25519'   # verify profile gating
chezmoi verify
chezmoi diff
chezmoi apply
cm pull   # alias: pull + apply (see ~/.zshrc)
```

## iTerm2 status bar (neo only)

`run_once_iterm_status_bar.py` runs on host `neo` via `run_once_package-configs.sh.tmpl`. Restart iTerm2 after apply.

## Zsh / OMZ one-time installs

Install Oh My Zsh, Powerlevel10k, and plugins manually (see comments in managed `~/.zprofile`), then `p10k configure`.

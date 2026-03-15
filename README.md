# Dotfiles (chezmoi)

[![Managed by chezmoi](https://img.shields.io/badge/managed_by-chezmoi-00b0b9)](https://www.chezmoi.io/) [![Personal dotfiles](https://img.shields.io/badge/use-reference_only-lightgrey)](#)

Managed by [chezmoi](https://www.chezmoi.io/). Includes zsh config (Oh My Zsh, Powerlevel10k, fzf, etc.), Cursor IDE settings, SSH agent + config, age-encrypted secrets, Homebrew (Brewfile), and Mac App Store apps (mas).

## First-time setup

1. **Install chezmoi** (if not already installed):
   - macOS: `brew install chezmoi`
   - Linux: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/twpayne/chezmoi/master/install.sh)"`

2. **Source location**: This repo is at `~/git/solaegis/neo-dotfiles`. Set `sourceDir = "~/git/solaegis/neo-dotfiles"` in `~/.config/chezmoi/chezmoi.toml`, then:
   ```bash
   chezmoi apply
   ```

3. **Git**: Work in `~/git/solaegis/neo-dotfiles` (clone, push, etc.). On another machine: clone to `~/git/solaegis/neo-dotfiles`, set `sourceDir = "~/git/solaegis/neo-dotfiles"` in `~/.config/chezmoi/chezmoi.toml`, then `chezmoi apply`. Or use `chezmoi init --apply <your-repo-url>`.

## What’s managed

| Source (in repo) | Target (on disk) |
|------------------|------------------|
| `dot_zprofile` | `~/.zprofile` |
| `dot_zshrc` | `~/.zshrc` |
| `dot_zsh/*.zsh` | `~/.zsh/*.zsh` |
| `private_dot_ssh/config` | `~/.ssh/config` (mode 0600) |
| `private_dot_ssh/*.enc` (age-encrypted) | `~/.ssh/id_*` (private keys) |
| `.chezmoidata.toml` | data for templates (edit here for brew/mas) |
| `Brewfile.tmpl` → | `~/Brewfile` (generated; run_once installs from it) |
| `mas-ids.txt.tmpl` → | `~/mas-ids.txt` (generated; run_once installs from it) |
| `dot_config/git/github-urls.config` | `~/.config/git/github-urls.config` |
| `dot_gitconfig` | `~/.gitconfig` (includeIf per ~/git/IDENTITY, includes github-urls.config) |
| `dot_gitconfig-acxiom` | `~/.gitconfig-acxiom` (used in ~/git/acxiom) |
| `dot_gitconfig-solaegis` | `~/.gitconfig-solaegis` (used in ~/git/solaegis) |
| `dot_gitconfig-dadandlad` | `~/.gitconfig-dadandlad` (used in ~/git/dadandlad) |
| `dot_gitconfig-nuvent` | `~/.gitconfig-nuvent` (used in ~/git/nuvent) |
| `Library/Application Support/Cursor/User/settings.json` | `~/Library/...` (macOS only) |
| `dot_config/Cursor/User/settings.json` | `~/.config/Cursor/User/settings.json` (Linux only) |

## SSH and encryption

- **SSH agent**: `~/.zprofile` starts the agent (if needed) and adds keys (GitHub identities: acxiom, solaegis, dadandlad, nuvent, plus `id_ed25519`/`id_rsa`). On macOS, passphrases are stored in Keychain.
- **SSH config**: `~/.ssh/config` maps GitHub host aliases (e.g. `github.com-acxiom`) to the right key.
- **GitHub URL rewrites**: `~/.config/git/github-urls.config` (included from `~/.gitconfig`) rewrites by org. **Directory-based**: clone into `~/git/acxiom`, `~/git/solaegis`, `~/git/dadandlad`, or `~/git/nuvent` and Git loads `~/.gitconfig-IDENTITY` for that path, so all GitHub URLs in that tree use the right key. Run_once creates the four directories; any repo under e.g. `~/git/acxiom` uses the acxiom key.
- **Age encryption** (for private keys in the repo):
  - One-time per machine: `brew install age` then `age-keygen -o ~/.config/chezmoi/age.key`. Set `CHEZMOI_AGE_IDENTITY_FILE=~/.config/chezmoi/age.key` (or add to `~/.config/chezmoi/chezmoi.toml`). Do not commit the key.
  - Add a key to the repo: `chezmoi add --encrypt ~/.ssh/id_ed25519_acxiom` (set `CHEZMOI_AGE_RECIPIENT` to your age public key when encrypting).
  - New host: install chezmoi + age, set the identity, then `chezmoi init --apply <repo>` (or clone and `chezmoi apply`).

## Homebrew and Mac App Store (data-driven)

- **Source of truth**: `.chezmoidata.toml` with three section types:
  - **All Macs**: `brew.mac` (formulae, casks), `mas.mac` (ids) — applied on every macOS machine.
  - **All Linux**: `brew.linux` (formulae, casks) — applied on every Linux machine.
  - **This host only**: `brew.hosts.<hostname>` and `mas.hosts.<hostname>` — applied only when `hostname` matches (e.g. `brew.hosts.neo`, `mas.hosts.neo` for machine "neo").
- **Generated at apply time**: `Brewfile.tmpl` → `~/Brewfile`, `mas-ids.txt.tmpl` → `~/mas-ids.txt`. Run_once scripts install from those files on first apply.
- **To add a formula/cask**: Edit the right section in `.chezmoidata.toml` (mac, linux, or hosts.neo), then `chezmoi apply`.
- **To add another machine**: Add `[brew.hosts.OTHERHOST]` and/or `[mas.hosts.OTHERHOST]` with `formulae = [...]`, `casks = [...]`, `ids = []` as needed.

## New host

1. Install chezmoi (and optionally age for encrypted files): `brew install chezmoi age` (or install chezmoi via the install script).
2. Generate age key if using encryption: `age-keygen -o ~/.config/chezmoi/age.key` and set `CHEZMOI_AGE_IDENTITY_FILE=~/.config/chezmoi/age.key`.
3. Clone to `~/git/solaegis/neo-dotfiles`, set `sourceDir = "~/git/solaegis/neo-dotfiles"` in `~/.config/chezmoi/chezmoi.toml`, then `chezmoi apply`. Or use `chezmoi init --apply <your-repo-url>`.
4. Run_once scripts will install Brewfile and (on macOS) mas apps; SSH config and agent setup apply from dotfiles.

## Useful commands

- `chezmoi status` — show what would change
- `chezmoi diff` — show diff of target files
- `chezmoi edit ~/.zshrc` — edit source file for `~/.zshrc`
- `chezmoi apply` — apply all changes
- `chezmoi re-add` — re-import existing files into source (e.g. after editing target)

## Zsh / OMZ one-time installs

See comments in `~/.zprofile` for:

- Homebrew formulae (or use the managed Brewfile)
- Oh My Zsh installer
- Powerlevel10k theme clone
- zsh-syntax-highlighting and zsh-autosuggestions clones

Then run `p10k configure` in a new shell to configure the prompt.

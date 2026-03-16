# Tier 2: SSH keys and gcloud (run on atreides)

Complete Tier 2 by running these on **atreides** (where the keys and gcloud config live).

## SSH keys

Add any missing keys to neo-dotfiles (age-encrypted):

```bash
cd ~/git/neo-dotfiles   # or your neo-dotfiles path
# Ensure CHEZMOI_AGE_RECIPIENT is set for encryption
chezmoi add --encrypt ~/.ssh/id_rsa_lv
chezmoi add --encrypt ~/.ssh/id_rsa_work
```

## gcloud config

1. On atreides, create encrypted tarball:

```bash
cd ~/.config
tar -czf /tmp/gcloud.tar gcloud
age -e -r YOUR_AGE_RECIPIENT -o gcloud.tar.age /tmp/gcloud.tar
```

2. Add to neo-dotfiles as `private_dot_config/gcloud/gcloud.tar.age`.

3. Run `chezmoi apply`. The run_once_restore_gcloud script will decrypt and extract on first apply.

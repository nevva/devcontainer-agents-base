#!/usr/bin/env bash
set -euo pipefail

# New volumes are owned by root; Docker also creates ~/.config as root for the gh mount.
sudo chown node:node /home/node/.config
sudo chown -R node:node /home/node/.claude /home/node/.codex /home/node/.config/gh

# Repo-local, so it overrides the host credentials VS Code forwards via system/global config.
git config --local --replace-all credential.https://github.com.helper ''
git config --local --add credential.https://github.com.helper '!gh auth git-credential'

npm install -g @openai/codex

welcome="$(cd "$(dirname "$0")" && pwd)/welcome.sh"
for rc in ~/.bashrc ~/.zshrc; do
  [ -f "$rc" ] || continue
  grep -qF "$welcome" "$rc" || echo "[[ \$- == *i* && -t 1 ]] && bash '$welcome'" >> "$rc"
done

---
name: dotfiles
description: Shared Mac and WSL machine config in ~/dotfiles; use before installing or upgrading a dev tool, or editing shell, git or env config or ~/.local/bin scripts.
---

- `~/dotfiles` (ryanhiizy/dotfiles) holds all shared config; `install.sh` symlinks it into `$HOME`. Edit there, commit and push; on the other machine `git pull && sh install.sh && mise install`.
- Dev tools come only from mise (`~/.config/mise/config.toml`): `mise use -g TOOL@latest` or `mise use -g npm:PKG@latest`, then `mise upgrade TOOL`. Never `npm i -g`, brew or apt for dev tools, curl installers, or a tool's own upgrade or self-update. Exceptions, vendor-installed into `~/.local/bin`: `blacksmith`, `terraform-mcp-server`.
- After `mise upgrade executor`, run `executor service install` (WSL: then `systemctl --user restart sh.executor.daemon.service`) so the background service runs the new version.
- Environment for every shell: `~/.config/shell/env.sh` (POSIX; zsh and Claude's bash both load it). Machine-only exports and secrets: `~/.config/shell/local.sh`. Machine-only git: `~/.config/git/local`. Neither is committed.
- Shell startup files only set variables: never start background processes (agents, daemons) from them; use the OS service (systemd user unit, launchd) and point a variable at it.
- Shared scripts: `.local/bin/` in the repo. Fetch tokens at runtime (`gh auth token`); never commit secrets.

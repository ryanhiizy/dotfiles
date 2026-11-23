#!/bin/sh
# Root setup for a WSL Ubuntu agent machine. Re-runnable. Run as: sudo sh ~/dotfiles/setup/ubuntu.sh
# Then, as the user: sh ~/dotfiles/install.sh && mise install
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
here=$(cd "$(dirname "$0")" && pwd)
user=${SUDO_USER:-ryanhiizy}

# Docker's own repository: Ubuntu's docker.io lags and lacks the buildx and compose plugins.
if [ ! -f /etc/apt/sources.list.d/docker.sources ]; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  . /etc/os-release
  printf 'Types: deb\nURIs: https://download.docker.com/linux/ubuntu\nSuites: %s\nComponents: stable\nSigned-By: /etc/apt/keyrings/docker.asc\n' "$VERSION_CODENAME" > /etc/apt/sources.list.d/docker.sources
fi
apt-get update -qq
grep -Ev '^\s*(#|$)' "$here/apt-packages.txt" | xargs apt-get install -y -qq
usermod -aG docker "$user"

# WSL: systemd on, the user logs in by default.
printf '[boot]\nsystemd=true\n[user]\ndefault=%s\n' "$user" > /etc/wsl.conf

# SSH: keys only.
printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\n' > /etc/ssh/sshd_config.d/10-keys-only.conf
systemctl enable --now ssh >/dev/null 2>&1 || true

# Kill the heaviest runaway process before memory runs out, instead of letting the VM freeze.
# -s 100 ignores swap, so compressed swap cannot hold the kill back while the machine thrashes.
# Test runners and builds go first; the agents, sshd and Docker's daemon are spared.
cat > /etc/default/earlyoom <<'CONF'
EARLYOOM_ARGS="-m 8 -s 100 -r 0 --prefer '(^|/)(node|python3?|pytest|vitest|playwright|chrome|chromium|oxlint|ty|esbuild|tsgo|cargo|rustc|go)$' --avoid '(^|/)(init|systemd|sshd|claude|codex|dockerd|containerd|tailscaled|earlyoom)$'"
CONF
systemctl enable earlyoom >/dev/null 2>&1; systemctl restart earlyoom
echo "ubuntu setup done"

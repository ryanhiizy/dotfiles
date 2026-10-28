# Shared by the Mac and WSL through ~/dotfiles, and by every shell: zsh sources it from
# .zshenv/.zprofile, bash (Claude Code's shell) from .bashrc. POSIX sh only. Machine-only
# exports and secrets go in ~/.config/shell/local.sh, which is never synced.

# Moves each directory to the front of PATH, keeping one copy.
path_prepend() {
  for dir in "$@"; do
    PATH=$(printf '%s' ":$PATH:" | sed "s#:$dir:#:#g; s#^:##; s#:\$##")
    PATH="$dir${PATH:+:$PATH}"
  done
}

# Order: hand-installed tools, then mise, then the OS package manager.
case $(uname -s) in
  Darwin)
    export HOMEBREW_PREFIX=/opt/homebrew HOMEBREW_CELLAR=/opt/homebrew/Cellar HOMEBREW_REPOSITORY=/opt/homebrew
    path_prepend /opt/homebrew/sbin /opt/homebrew/bin
    ;;
  Linux)
    PATH="$PATH:$HOME/.local/share/google-cloud-sdk/bin:/snap/bin"
    # One ssh-agent per user from systemd's ssh-agent.socket; a forwarded agent wins.
    agent="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/openssh_agent"
    [ -z "${SSH_AUTH_SOCK:-}" ] && [ -S "$agent" ] && export SSH_AUTH_SOCK="$agent"
    unset agent
    # Web URLs open in the Mac's browser.
    [ -x "$HOME/.local/bin/remote-access-browser" ] && export BROWSER="$HOME/.local/bin/remote-access-browser"
    # Size the vitest pool from free memory (about 1.5 GB per worker, 2 to all cores), so
    # an idle machine runs wide and concurrent agent runs can't exhaust RAM.
    VITEST_MAX_WORKERS=$(awk -v cores="$(nproc)" '/^MemAvailable:/ { n = int($2 / 1572864); if (n < 2) n = 2; if (n > cores) n = cores; print n }' /proc/meminfo)
    export VITEST_MAX_WORKERS
    ;;
esac
path_prepend "$HOME/.local/share/mise/shims" "$HOME/.local/bin"
export PATH

[ -r "$HOME/.config/shell/local.sh" ] && . "$HOME/.config/shell/local.sh"
unset -f path_prepend

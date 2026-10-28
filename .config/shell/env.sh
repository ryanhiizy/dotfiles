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
    # Remote Ender development signs in to AWS with a device code.
    export ENDER_LOCAL_AWS_LOGIN_MODE=device-code
    export ENDER_PDF_INSPECTOR_CACHE_DIR="${ENDER_PDF_INSPECTOR_CACHE_DIR:-$HOME/.cache/ender/pdf-inspector}"
    # Web URLs open in the Mac's browser.
    [ -x "$HOME/.local/bin/remote-access-browser" ] && export BROWSER="$HOME/.local/bin/remote-access-browser"
    [ -r "$HOME/.config/vitest-workers.sh" ] && . "$HOME/.config/vitest-workers.sh"
    ;;
esac
path_prepend "$HOME/.local/share/mise/shims" "$HOME/.local/bin"
export PATH

[ -r "$HOME/.config/shell/local.sh" ] && . "$HOME/.config/shell/local.sh"
unset -f path_prepend

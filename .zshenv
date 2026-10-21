# Shared by the Mac and WSL through ~/dotfiles. Machine-only settings
# and secrets go in ~/.config/zsh/local.zsh, which is never synced.
source "$HOME/.config/zsh/path.zsh"

if [[ $OSTYPE == linux* ]]; then
  # Remote Ender development signs in to AWS with a device code.
  export ENDER_LOCAL_AWS_LOGIN_MODE=device-code
  export ENDER_PDF_INSPECTOR_CACHE_DIR="${ENDER_PDF_INSPECTOR_CACHE_DIR:-$HOME/.cache/ender/pdf-inspector}"
  # Web URLs open in the Mac's browser.
  [[ -x $HOME/.local/bin/remote-access-browser ]] && export BROWSER="$HOME/.local/bin/remote-access-browser"
  [[ -r $HOME/.config/vitest-workers.sh ]] && source "$HOME/.config/vitest-workers.sh"
fi

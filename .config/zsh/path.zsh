# One PATH for every shell. Order: hand-installed tools, then mise, then the OS
# package manager. typeset -U keeps the first copy, so re-sourcing is safe.
typeset -U path
if [[ $OSTYPE == darwin* ]]; then
  export HOMEBREW_PREFIX=/opt/homebrew HOMEBREW_CELLAR=/opt/homebrew/Cellar HOMEBREW_REPOSITORY=/opt/homebrew
  path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
else
  path=($path $HOME/.local/share/google-cloud-sdk/bin /snap/bin)
fi
path=($HOME/.local/bin $HOME/.local/share/mise/shims $path)
export PATH

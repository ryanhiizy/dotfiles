# Shared by the Mac and WSL through ~/dotfiles. Machine-only settings
# and secrets go in ~/.config/zsh/local.zsh, which is never synced.

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY INC_APPEND_HISTORY SHARE_HISTORY HIST_EXPIRE_DUPS_FIRST \
  HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_IGNORE_SPACE \
  HIST_SAVE_NO_DUPS HIST_VERIFY HIST_REDUCE_BLANKS

# Completion
setopt AUTO_MENU COMPLETE_IN_WORD ALWAYS_TO_END AUTO_LIST AUTO_PARAM_SLASH NO_MENU_COMPLETE EXTENDED_GLOB
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true

eval "$(mise activate zsh)"
# Ctrl-R history, Ctrl-T files, Alt-C directories. Loaded before fzf-tab so
# fzf-tab, not fzf's own completion, owns Tab.
source <(fzf --zsh)

# Plugins: antidote compiles ~/.zsh_plugins.txt into ~/.zsh_plugins.zsh and
# rebuilds it only when the list changes.
ANTIDOTE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/antidote"
[[ -d ${ZDOTDIR:-$HOME}/.antidote ]] ||
  git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}/.antidote"
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  source "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh"
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '\e[1;5D' backward-word
bindkey '\e[1;5C' forward-word
bindkey '\e[3;5~' kill-word
bindkey '^H' backward-kill-word

eval "$(zoxide init zsh --cmd z)"
command -v wt >/dev/null && eval "$(command wt config shell init zsh)"

if [[ $OSTYPE == linux* ]]; then
  # A Windows SSH session starts in System32.
  [[ $PWD == /mnt/c/* ]] && cd ~
  alacritty() { "/mnt/c/Program Files/Alacritty/alacritty.exe" "$@"; }
  if [[ -z $SSH_AUTH_SOCK ]]; then
    eval "$(ssh-agent -s)" >/dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
  fi
fi

[[ -r $HOME/.config/zsh/local.zsh ]] && source "$HOME/.config/zsh/local.zsh"
[[ -r $HOME/.p10k.zsh ]] && source "$HOME/.p10k.zsh"

# fzf-tab needs compinit to have run, and it must load before plugins that wrap
# widgets, so compinit sits between them in the plugin list. The dump is rebuilt
# at most once a day.
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

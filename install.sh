#!/bin/sh
# Links every tracked file into $HOME. Re-runnable: an existing real file is
# moved to <name>.pre-dotfiles before its link is created.
set -eu
repo=$(cd "$(dirname "$0")" && pwd)
cd "$repo"
git ls-files | grep -vE '^(install\.sh|\.gitignore)$' | while read -r f; do
  target="$HOME/$f"
  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.pre-dotfiles"
  fi
  ln -sfn "$repo/$f" "$target"
  echo "linked $f"
done

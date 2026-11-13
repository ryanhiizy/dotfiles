#!/bin/sh
# Links every tracked file into $HOME. Re-runnable: an existing real file is
# moved to <name>.pre-dotfiles before its link is created.
set -eu
repo=$(cd "$(dirname "$0")" && pwd)
cd "$repo"
# Links are relative, as GNU Stow makes them: skills-sync copies ~/.agents between the
# Mac and WSL, whose home paths differ, so an absolute link breaks on the other machine.
case $repo in
  "$HOME"/*) base=${repo#"$HOME"/} ;;
  *) base= ;;
esac
git ls-files | grep -vE '^(install\.sh|\.gitignore)$' | while read -r f; do
  target="$HOME/$f"
  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.pre-dotfiles"
  fi
  if [ -n "$base" ]; then
    up=$(printf '%s\n' "$f" | sed 's|[^/]*/|../|g; s|[^/]*$||')
    ln -sfn "$up$base/$f" "$target"
  else
    ln -sfn "$repo/$f" "$target"
  fi
  echo "linked $f"
done

# Claude Code and Codex each load skills from their own directory; every shared skill
# lives in ~/.agents/skills, so link each one in. Existing entries are left alone.
for skill in "$HOME"/.agents/skills/*/; do
  [ -d "$skill" ] || continue
  name=$(basename "$skill")
  for dir in "$HOME/.claude/skills" "$HOME/.codex/skills"; do
    [ -d "$(dirname "$dir")" ] || continue
    mkdir -p "$dir"
    [ -e "$dir/$name" ] || [ -L "$dir/$name" ] || { ln -s "../../.agents/skills/$name" "$dir/$name"; echo "linked skill $name → $dir"; }
  done
done

#!/usr/bin/env bash

set -euo pipefail

CURDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${STOW_TARGET:-$HOME}"
BACKUP_DIR="${STOW_BACKUP_DIR:-$TARGET/.dotfiles-backup/$(date +%Y%m%d%H%M%S)}"
STOW_IGNORE_ARGS=(--ignore='lazy-lock\.json' --ignore='init\.lua')

if [[ "${EUID:-$(id -u)}" -eq 0 && -z "${STOW_TARGET:-}" ]]; then
  echo "Do not run this script with sudo unless STOW_TARGET is set explicitly." >&2
  exit 1
fi

cd "$CURDIR"

echo "Stowing dotfiles into $TARGET"

function backup_conflicts {
  local folder="$1"
  local path relative target_path backup_path

  while IFS= read -r path; do
    relative="${path#"$folder"/}"
    target_path="$TARGET/$relative"

    if [[ -e "$target_path" || -L "$target_path" ]]; then
      backup_path="$BACKUP_DIR/$relative"
      mkdir -p "$(dirname "$backup_path")"
      echo "Backing up existing $target_path -> $backup_path"
      mv "$target_path" "$backup_path"
    fi
  done < <(git ls-files --cached --others --exclude-standard "$folder")
}

for folder in claude codex ghostty git herdr nvim vim zsh tmux; do
  [[ -d "$folder" ]] || continue
  echo "Linking $folder"
  stow "${STOW_IGNORE_ARGS[@]}" -D -t "$TARGET" "$folder"
  backup_conflicts "$folder"
  stow "${STOW_IGNORE_ARGS[@]}" -t "$TARGET" "$folder"
done

nvim_init="$TARGET/.config/nvim/init.lua"
for name in init.online.lua init.offline.lua; do
  if [[ ! "$TARGET/.config/nvim/$name" -ef "$CURDIR/nvim/.config/nvim/$name" ]]; then
    echo "Neovim configuration was not linked correctly: $TARGET/.config/nvim/$name" >&2
    exit 1
  fi
done
# -e follows symlinks: repair a dangling selector as well as a missing one.
if [[ ! -e "$nvim_init" ]]; then
  ln -sfn init.offline.lua "$nvim_init"
  echo "Defaulting Neovim to init.offline.lua"
fi

echo "Done."

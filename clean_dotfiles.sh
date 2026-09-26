#!/usr/bin/env bash

set -euo pipefail

CURDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${STOW_TARGET:-$HOME}"
STOW_IGNORE_ARGS=(--ignore='lazy-lock\.json')

if [[ "${EUID:-$(id -u)}" -eq 0 && -z "${STOW_TARGET:-}" ]]; then
  echo "Do not run this script with sudo unless STOW_TARGET is set explicitly." >&2
  exit 1
fi

cd "$CURDIR"

echo "Unlinking dotfiles from $TARGET"

# Preserve an old selector's choice while migrating to named configurations.
nvim_init="$TARGET/.config/nvim/init.lua"
if [[ -L "$nvim_init" ]]; then
  case "$(readlink "$nvim_init")" in
  init.online.lua | init.offline.lua | "$TARGET/.config/nvim/init.online.lua" | "$TARGET/.config/nvim/init.offline.lua")
    mode_file="${XDG_STATE_HOME:-$TARGET/.local/state}/nvim-mode"
    if [[ ! -f "$mode_file" ]]; then
      mode=nvim-nopack
      [[ "$(readlink "$nvim_init")" == *init.online.lua ]] && mode=nvim
      mkdir -p "$(dirname "$mode_file")"
      printf '%s\n' "$mode" >"$mode_file"
    fi
    rm "$nvim_init"
    ;;
  esac
fi

for folder in claude codex ghostty git nvim nvim-nopack vim tmux zsh; do
  [[ -d "$folder" ]] || continue
  echo "Unlinking $folder"
  stow "${STOW_IGNORE_ARGS[@]}" -D -t "$TARGET" "$folder"
done

echo "Done."

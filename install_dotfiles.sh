#!/usr/bin/env bash

set -euo pipefail

CURDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${STOW_TARGET:-$HOME}"
BACKUP_DIR="${STOW_BACKUP_DIR:-$TARGET/.dotfiles-backup/$(date +%Y%m%d%H%M%S)}"
STOW_IGNORE_ARGS=(--ignore='lazy-lock\.json')

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
    [[ -e "$path" || -L "$path" ]] || continue
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

# Migrate the old symlink selector before Stow replaces it.
nvim_init="$TARGET/.config/nvim/init.lua"
mode_file="${XDG_STATE_HOME:-$TARGET/.local/state}/nvim-mode"
if [[ ! -f "$mode_file" ]]; then
  mode=nvim-nopack
  if [[ -L "$nvim_init" ]]; then
    case "$(readlink "$nvim_init")" in
    *init.online.lua) mode=nvim ;;
    esac
  fi
  mkdir -p "$(dirname "$mode_file")"
  printf '%s\n' "$mode" >"$mode_file"
fi

# Remove a directory link installed under the previous app name.
legacy_config="$TARGET/.config/nvim-offline"
if [[ -L "$legacy_config" ]]; then
  case "$(readlink "$legacy_config")" in
  */nvim-offline/.config/nvim-offline) rm "$legacy_config" ;;
  esac
fi
if [[ "$(cat "$mode_file")" == nvim-offline ]]; then
  printf 'nvim-nopack\n' >"$mode_file"
fi

for folder in claude codex ghostty git herdr nvim nvim-nopack neovide-terminal vim zsh tmux; do
  [[ -d "$folder" ]] || continue
  echo "Linking $folder"
  stow "${STOW_IGNORE_ARGS[@]}" -D -t "$TARGET" "$folder"
  backup_conflicts "$folder"
  stow "${STOW_IGNORE_ARGS[@]}" -t "$TARGET" "$folder"
done

for app in nvim nvim-nopack neovide-terminal; do
  if [[ ! "$TARGET/.config/$app/init.lua" -ef "$CURDIR/$app/.config/$app/init.lua" ]]; then
    echo "Neovim configuration was not linked correctly: $TARGET/.config/$app/init.lua" >&2
    exit 1
  fi
done

# Preserve nopack sessions, undo files and tags from the shared data directory.
data_home="${XDG_DATA_HOME:-$TARGET/.local/share}"
for base in "$data_home" "${XDG_STATE_HOME:-$TARGET/.local/state}" "${XDG_CACHE_HOME:-$TARGET/.cache}"; do
  if [[ -d "$base/nvim-offline" && ! -e "$base/nvim-nopack" ]]; then
    mv "$base/nvim-offline" "$base/nvim-nopack"
  fi
done
mkdir -p "$data_home/nvim-nopack"
if [[ -d "$data_home/nvim/offline" && ! -e "$data_home/nvim-nopack/nopack" ]]; then
  mv "$data_home/nvim/offline" "$data_home/nvim-nopack/nopack"
fi
if [[ -d "$data_home/nvim-nopack/offline" && ! -e "$data_home/nvim-nopack/nopack" ]]; then
  mv "$data_home/nvim-nopack/offline" "$data_home/nvim-nopack/nopack"
fi
# Existing Mason executables remain available without loading pack plugins.
if [[ ! -e "$data_home/nvim-nopack/mason" && ! -L "$data_home/nvim-nopack/mason" ]]; then
  ln -s "$data_home/nvim/mason" "$data_home/nvim-nopack/mason"
fi

echo "Done."

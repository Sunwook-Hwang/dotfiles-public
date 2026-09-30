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

# Remove only links owned by the retired profile/launcher layout.
for legacy in "$TARGET/.config/nvim-nopack" "$TARGET/.local/libexec/dotfiles/vi"; do
  if [[ -L "$legacy" ]]; then
    case "$(readlink "$legacy")" in
      *nvim-nopack/.config/nvim-nopack|*tools/.local/libexec/dotfiles/vi) unlink "$legacy" ;;
    esac
  fi
done

for folder in claude codex ghostty git herdr nvim nvim-pack neovide-terminal vim zsh csh tmux tools; do
  [[ -d "$folder" ]] || continue
  echo "Linking $folder"
  stow "${STOW_IGNORE_ARGS[@]}" -D -t "$TARGET" "$folder"
  backup_conflicts "$folder"
  stow "${STOW_IGNORE_ARGS[@]}" -t "$TARGET" "$folder"
done

for app in nvim nvim-pack neovide-terminal; do
  if [[ ! "$TARGET/.config/$app/init.lua" -ef "$CURDIR/$app/.config/$app/init.lua" ]]; then
    echo "Neovim configuration was not linked correctly: $TARGET/.config/$app/init.lua" >&2
    exit 1
  fi
done

# Keep installed plugins and tools with pack; sessions/undo remain shared under nvim.
data_home="${XDG_DATA_HOME:-$TARGET/.local/share}"
mkdir -p "$data_home/nvim" "$data_home/nvim-pack"
for item in site mason; do
  if [[ -d "$data_home/nvim/$item" && ! -L "$data_home/nvim/$item" && ! -e "$data_home/nvim-pack/$item" ]]; then
    mv "$data_home/nvim/$item" "$data_home/nvim-pack/$item"
  fi
done
if [[ -d "$data_home/nvim-nopack/nopack" && ! -e "$data_home/nvim/nopack" ]]; then
  mv "$data_home/nvim-nopack/nopack" "$data_home/nvim/nopack"
fi
# FLASH can use already installed Mason tools without loading any plugins.
if [[ ! -e "$data_home/nvim/mason" && ! -L "$data_home/nvim/mason" ]]; then
  ln -s "$data_home/nvim-pack/mason" "$data_home/nvim/mason"
fi

echo "Done."

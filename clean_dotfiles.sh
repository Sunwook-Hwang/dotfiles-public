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

for folder in claude codex git nvim tmux zsh; do
    [[ -d "$folder" ]] || continue
    echo "Unlinking $folder"
    stow "${STOW_IGNORE_ARGS[@]}" -D -t "$TARGET" "$folder"
done

echo "Done."

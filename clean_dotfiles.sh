#!/bin/sh
for folder in git lvim nvim tmux zsh; do
    echo "Clean.. $folder"
    stow -D $folder;
done


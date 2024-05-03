#!/bin/sh

for folder in bujo wezterm alacritty git lvim nvim zsh tmux;do
    stow -D $folder;
    stow --adopt $folder;
done


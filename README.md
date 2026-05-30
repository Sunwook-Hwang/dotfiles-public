# Dotfiles

macOS-focused dotfiles for zsh, git, tmux, and Neovim.

## Setup

macOS:

```sh
git clone --depth 1 https://github.com/Sunwook-Hwang/dotfiles ~/dotfiles
cd ~/dotfiles
./mac_setup.sh
```

Linux:

```sh
git clone --depth 1 https://github.com/Sunwook-Hwang/dotfiles ~/dotfiles
cd ~/dotfiles
./linux_setup.sh
```

Install only Homebrew packages:

```sh
./mac_setup.sh base
```

Update Homebrew itself:

```sh
./mac_setup.sh brew
```

Install only Linux packages:

```sh
./linux_setup.sh base
```

Link or unlink dotfiles on either platform:

```sh
./mac_setup.sh link
./mac_setup.sh unlink
./linux_setup.sh link
./linux_setup.sh unlink
```

## Included

- `zsh`: oh-my-zsh config and shell aliases
- `claude`: global Claude Code guidance
- `codex`: global Codex guidance
- `git`: git defaults
- `tmux`: tmux keybindings and theme
- `nvim`: Neovim config

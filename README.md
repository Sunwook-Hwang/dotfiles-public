# Dotfiles

macOS-focused dotfiles for zsh, git, Herdr, tmux, and Neovim.

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
- `herdr`: terminal multiplexer keybindings
- `tmux`: tmux keybindings and theme
- `nvim`: Neovim config

## Offline Neovim

For restricted servers, use [`init.offline.lua`](nvim/.config/nvim/init.offline.lua).
It requires **Neovim 0.12+** and runs from a single configuration file using
Neovim's bundled runtime and existing system tools. It does not download
plugins, parsers, language servers, or formatters.

With the Stow setup:

```sh
nvim -u ~/.config/nvim/init.offline.lua
```

On a server, copy that one file and run it directly:

```sh
nvim -u /path/to/init.offline.lua
```

To use it by default, back up your existing configuration and place the file at
`${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.lua`. The normal plugin-based
[`init.lua`](nvim/.config/nvim/init.lua) remains a separate option.

| Feature | Offline behavior |
| --- | --- |
| Completion | Native LSP completion on server-defined triggers; buffer words and ctags fallback without LSP |
| Completion keys | `Ctrl-Space` requests candidates, `Ctrl-n/p` selects, `Enter` accepts; `Tab` / `Shift-Tab` navigates snippets or candidates |
| Definition | `gd` uses LSP first, then saved-file ctags definitions |
| LSP | Native client; `Space ls` restarts current-buffer clients, `Space lv` selects the Python environment |
| Formatting | `Space lf` runs installed formatters asynchronously or falls back to LSP; no format-on-save |
| Search | `Space f` finds files, `Space Enter` finds Git-tracked files, `Space st` searches text live, `Space t` searches the cursor word |
| Code outline | `Space Tr` opens LSP symbols or a ctags fallback; `Enter` jumps, `r` refreshes, `q` closes |
| File tree | `Space e` toggles netrw at the project root with cached Git status signs |
| Git | Unstaged line signs, branch/file status, and side-by-side index/HEAD diff with `Space gd/gD` |
| Terminal | `Ctrl-t` toggles a reusable bottom split; `Esc Esc` exits Terminal mode |
| Auto pairs | Brackets `() [] {}`, single/double quotes, and backticks; skip existing closers and delete empty pairs |
| Undo | `Space Tu` previews saved undo states before applying one |
| Highlighting | Bundled Treesitter parsers when available, otherwise syntax highlighting; native indent guides |

LSP and formatter launchers are searched in
`${XDG_CONFIG_HOME:-$HOME/.config}/nvim/lsp/bin` before `PATH`.
LSP also checks an existing `stdpath("data")/mason/bin` directory without loading
Mason or installing tools. Auxiliary servers require project configuration or
dependencies. Ctags fallback supports C/C++ and Python using Universal or
Exuberant Ctags. Search uses installed `find`, `git`, and `rg` or `grep`.

Large files disable expensive editing features. Ctags cache merging runs in a
worker thread, and Git/tree/tabline caches avoid repeated work during editing.
The built-in picker and outline provide a smaller feature set than Telescope
and Aerial; Which-key popups and DAP are not included.

See [the key guide, ctags setup, and limits](docs/nvim-offline.md) and
[LSP/formatter installation and offline transfer](docs/nvim-offline-tools.md).

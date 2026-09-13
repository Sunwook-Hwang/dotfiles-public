# Dotfiles

macOS-focused dotfiles for zsh, git, Herdr, tmux, and Neovim.

## Package-free Native Neovim

This repository includes [`init.offline.lua`](nvim/.config/nvim/init.offline.lua),
a **single-file, package-free Native Neovim configuration** for Neovim 0.12+.
It uses no plugin manager and no external Lua plugins, and it performs no plugin
or parser downloads. Built-in replacements provide a dashboard, fuzzy pickers,
a file tree, a Space-key guide, Sticky Scroll, Git signs and inline blame, LSP,
completion, formatting, sessions, an undo browser, and a reusable terminal.

Optional language servers, formatters, and command-line search tools are used
only when already installed. See the feature guide in
[English](docs/nvim-offline-features.md) or
[한국어](docs/nvim-offline-features.ko.md).

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

## Git identity

Set your name and email in a local file that is not part of this repository:

```bash
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "you@example.com"
```

The shared `.gitconfig` includes this optional file. Use it for personal Git
settings instead of adding them to the shared configuration.

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

To use it by default, point `${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.lua`
at either `init.online.lua` or `init.offline.lua`. This repository defaults to
`init.offline.lua`. The `onvi` and `offvi` shell aliases switch that symlink and
then start Neovim. The local `init.lua` symlink is ignored by Git, so switching
modes does not change the working tree.

When an update adds or renames configuration files, `git pull` alone does not
create new file-level Stow links. From the repository, run:

```sh
git pull --ff-only
./clean_dotfiles.sh
./install_dotfiles.sh
```

The installer verifies both Neovim configuration links and repairs a missing or
dangling `init.lua`. A clean install defaults to offline mode; use `onvi` to select
online mode. Custom `init.lua` files are preserved.

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

LSP and formatter launchers are searched on `PATH` first, then in an existing `stdpath("data")/mason/bin` directory without loading
Mason or installing tools. Auxiliary servers require project configuration or
dependencies. Ctags fallback supports C/C++ and Python using Universal or
Exuberant Ctags. Search uses installed `find`, `git`, and `rg` or `grep`.

Large files disable expensive editing features. Ctags cache merging runs in a
worker thread, and Git/tree/tabline caches avoid repeated work during editing.
The built-in picker and outline provide a smaller feature set than Telescope
and Aerial; a native Space-key guide replaces Which-key, while DAP is not included.

See the offline feature overview in [English](docs/nvim-offline-features.md) or
[한국어](docs/nvim-offline-features.ko.md),
[implementation details, ctags setup, and limits](docs/nvim-offline.md), and
[LSP/formatter installation and offline transfer](docs/nvim-offline-tools.md).

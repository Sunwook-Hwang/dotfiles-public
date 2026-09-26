# Dotfiles

macOS-focused dotfiles for zsh, git, Herdr, tmux, Neovim, and Vim.

## Package-free Native Neovim

This repository includes [`nvim-nopack/init.lua`](nvim-nopack/.config/nvim-nopack/init.lua),
a **package-free Native Neovim configuration** for Neovim 0.12+.
It uses no plugin manager and no external Lua plugins, and it performs no plugin
or parser downloads. Built-in replacements provide a dashboard, fuzzy pickers,
a file tree, a Space-key guide, Sticky Scroll, Git signs and inline blame, LSP,
completion, formatting, sessions, an undo browser, and a reusable terminal.

Optional language servers, formatters, and command-line search tools are used
only when already installed. See the feature guide in
[English](docs/nvim-nopack-features.md) or
[한국어](docs/nvim-nopack-features.ko.md).

For **Vim 9.0+**, [`vim/.vimrc`](vim/.vimrc) provides a standalone, plugin-free
Vimscript counterpart with the same core shortcuts. It uses **ctags instead of
LSP**, with native commenting, completion, pickers, netrw, Git, formatting,
dashboard, Sticky Scroll, sessions, and undo previews. No Lua support is needed.
See the Vim guide in [English](docs/vim-nopack-features.md) or
[한국어](docs/vim-nopack-features.ko.md).

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

Run the complete first-time macOS setup (equivalent to `./mac_setup.sh`):

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
- `nvim`: pack Neovim config
- `nvim-nopack`: modular, package-free Neovim config
- `neovide-terminal`: standalone Neovide terminal config
- `vim`: single-file nopack Vim 9.0+ config (`~/.vimrc`)

## Git identity

Set your name and email in a local file that is not part of this repository:

```bash
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "you@example.com"
```

The shared `.gitconfig` includes this optional file. Use it for personal Git
settings instead of adding them to the shared configuration.

## Nopack Neovim

For restricted servers, use [`nvim-nopack/init.lua`](nvim-nopack/.config/nvim-nopack/init.lua).
It requires **Neovim 0.12+** and uses feature modules under its own `lua/` directory with
Neovim's bundled runtime and existing system tools. It does not download
plugins, parsers, language servers, or formatters.

With the Stow setup:

```sh
NVIM_APPNAME=nvim-nopack nvim
```

On a server, copy `init.lua` and its adjacent `lua/` directory together, then run:

```sh
nvim -u /path/to/init.lua
```

Pack configuration is installed at `~/.config/nvim/init.lua`, with feature
modules in its adjacent `lua/` directory. Nopack is installed separately at
`~/.config/nvim-nopack/`, with its own `init.lua` and `lua/` directory.
See [Nopack configuration structure](docs/nvim-nopack-structure.md) for module responsibilities.

`pvi` selects pack mode; `npvi` selects nopack mode. Both start Neovim and
save the choice. After that, `vi` uses the last selection, including in a new
terminal. A fresh installation defaults to nopack mode. The launcher sets
`NVIM_APPNAME=nvim` or `nvim-nopack`, keeping configuration, cache, and state
paths separate. Persistent undo is shared at
`${XDG_STATE_HOME:-$HOME/.local/state}/nvim/undo` so saved history follows a file
between modes. Plain `nvim` uses pack mode unless `NVIM_APPNAME` is set.

The selector is stored locally in `${XDG_STATE_HOME:-$HOME/.local/state}/nvim-mode`.
Existing nopack sessions, undo files, and tags are migrated to
`~/.local/share/nvim-nopack/nopack` during installation. Existing pack Mason
tools remain available to nopack through a link; nopack does not load Mason or
pack plugins.

With the repository’s `.zshrc` loaded:

```sh
pvi
npvi
vi
```

Neovide uses a separate terminal profile at `~/.config/neovide-terminal/init.lua`:

```sh
NVIM_APPNAME=neovide-terminal neovide
```

On macOS, `./mac_setup.sh` and `./mac_setup.sh base` install Neovide and configures its app icon to open
this terminal profile automatically. You can also set up just this integration
with `./mac_setup.sh neovide`. The app is available at
`~/Applications/Neovide.app` and can be dragged to the Dock.

The `neovide` shell alias selects this profile. The shell inside Neovide does not
inherit that profile, so nested Neovim can use pack or nopack independently.

When copying pack configuration to another machine, include the adjacent
`lua/` directory. See [Pack configuration structure](docs/nvim-pack-structure.md).

When an update adds or renames configuration files, `git pull` alone does not
create new file-level Stow links. From the repository, run:

```sh
git pull --ff-only
./clean_dotfiles.sh
./install_dotfiles.sh
```

The installer verifies both named configuration links and the launcher. Existing
conflicting files are backed up before installation. Mode selection survives
clean/reinstall; a fresh install defaults to nopack.

| Feature         | Nopack behavior                                                                                                                 |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Completion      | Native LSP completion on server-defined triggers; buffer words and ctags fallback without LSP                                   |
| Completion keys | `Ctrl-Space` requests candidates, `Ctrl-n/p` selects, `Enter` accepts; `Tab` / `Shift-Tab` navigates snippets or candidates     |
| Definition      | `gd` uses LSP first, then saved-file ctags definitions                                                                          |
| LSP             | Native client; `Space ls` restarts current-buffer clients, `Space lv` selects the Python environment                            |
| Formatting      | `Space lf` runs installed formatters asynchronously or falls back to LSP; no format-on-save                                     |
| Search          | `Space f` finds files, `Space Enter` finds Git-tracked files, `Space st` searches text live, `Space t` searches the cursor word |
| Code outline    | `Space o` opens LSP symbols or a ctags fallback; `Enter` jumps, `r` refreshes, `q` closes                                       |
| File tree       | `Space e` toggles netrw at the project root with cached Git status signs                                                        |
| Git             | Unstaged line signs, branch/file status, and side-by-side index/HEAD diff with `Space gd/gD`                                    |
| Terminal        | `Ctrl-t` toggles a reusable bottom split; `Esc Esc` exits Terminal mode                                                         |
| Auto pairs      | Brackets `() [] {}`, single/double quotes, and backticks; skip existing closers and delete empty pairs                          |
| Undo            | `Space u` previews saved undo states before applying one                                                                        |
| Highlighting    | Bundled Treesitter parsers when available, otherwise syntax highlighting; native indent guides                                  |

LSP and formatter launchers are searched on `PATH` first, then in an existing `stdpath("data")/mason/bin` directory without loading
Mason or installing tools. Auxiliary servers require project configuration or
dependencies. Ctags fallback supports C/C++ and Python using Universal or
Exuberant Ctags. Search uses installed `find`, `git`, and `rg` or `grep`.

Large files disable expensive editing features. Ctags cache merging runs in a
worker thread, and Git/tree/tabline caches avoid repeated work during editing.
The built-in picker and outline provide a smaller feature set than Telescope
and Aerial; a native Space-key guide replaces Which-key, while DAP is not included.

See the nopack feature overview in [English](docs/nvim-nopack-features.md) or
[한국어](docs/nvim-nopack-features.ko.md),
[implementation details, ctags setup, and limits](docs/nvim-nopack.md), and
[LSP/formatter installation and transfer to network-isolated servers](docs/nvim-nopack-tools.md).

## Formatting

Project formatter configuration is stored in the repository and used by pvi,
npvi, and Vim. See [Formatting rules](docs/formatting.md) for per-language settings
and reuse in other projects.

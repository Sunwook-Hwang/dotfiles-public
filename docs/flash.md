# FLASH — Native Neovim Guide

[English](flash.md) | [한국어](flash.ko.md)

`nvim/.config/nvim/init.lua` is a **package-free, native Neovim configuration** organized
into feature modules for Neovim 0.12+. It has no plugin manager, no external Lua
plugins, and no parser download step. It uses only Neovim's built-in APIs,
bundled runtime, and system commands that are already installed.

LSP servers and formatters are optional executables. The configuration detects
the tools it knows about but never downloads, installs, or updates them.

- Configuration: `nvim/.config/nvim/init.lua` and its adjacent `lua/` directory
- Required version: Neovim 0.12 or newer

Contents:

- [Starting Neovim and the dashboard](#starting-neovim-and-the-dashboard)
- [Interface](#interface)
- [Native Space-key guide](#native-space-key-guide)
- [Files and buffers](#files-and-buffers)
- [Search and picker UI](#search-and-picker-ui)
- [Git](#git)
- [LSP, completion, and diagnostics](#lsp-completion-and-diagnostics)
- [Formatting](#formatting)
- [Undo, sessions, and terminal](#undo-sessions-and-terminal)
- [Editing conveniences](#editing-conveniences)
- [Performance and safety limits](#performance-and-safety-limits)
- [Deliberately unsupported](#deliberately-unsupported)
- [Tool setup and server transfer](#tool-setup-and-server-transfer)
- [Ctags fallback](#ctags-fallback)
- [Configuration structure](#configuration-structure)

## Starting Neovim and the dashboard

```sh
NVIM_APPNAME=nvim nvim
```

Starting without a file opens a native dashboard. Move with `j/k` or the arrow
keys and press `Enter`. The cursor stays on selectable rows.

| Key       | Action                               |
| --------- | ------------------------------------ |
| `f`       | Find project files                   |
| `r`       | Open recent files                    |
| `l`       | Restore the last session             |
| `p`       | Select a saved session               |
| `n`       | Create a new file                    |
| `c`       | Open the active Neovim configuration |
| `q`       | Quit                                 |
| `Space A` | Reopen the dashboard while editing   |

Passing a file argument skips the dashboard and opens that file directly.

The dashboard uses a dedicated floating window. `Esc` closes it without changing
the underlying editor's buffer, cursor, scroll position, or window options.
Menu actions and direct `:edit` commands open files in the original editor window.

## Interface

### Status line

The left side shows the Git branch and state followed by the filename. The
right side shows diagnostics, LSP and formatter availability, filetype, and a
fixed-width cursor position.

```text
[master .M] file.lua [+]    E: 1 W: 2 [LSP: lua_ls] [FORMAT: stylua] lua |  123:  8 |  42%
```

- Diagnostic groups with a count of zero are hidden.
- Without LSP, supported ctags is shown as `[CTAGS: Universal]` or `[CTAGS: Exuberant]`; otherwise `[LSP X]` has a highlighted background.
- `[FORMAT X]` means no formatter is currently available.
- `[FORMAT: name]` names the external formatter or LSP used for this buffer.
- `Space Tl` toggles both the LSP and formatter status sections.
- `Space Td` toggles native statusline breadcrumbs (`path > class > function`) from cached LSP symbols; click a symbol to jump to its declaration. Without symbol support, only the path is shown. No code-text or indentation guesses are used.

### Buffers, indent guides, and Sticky Scroll

- The native tabline displays open buffers and modified state.
- `Alt-1..8` selects that numbered buffer; `Alt-9` selects the last buffer.
- Indent guides use `┊` and follow the file's `shiftwidth`.
- Sticky Scroll is off by default and keeps up to eight enclosing function, conditional, and loop lines when enabled.
- Sticky rows preserve real line numbers, indentation, syntax highlighting, and a separator.
- `Space Ti` toggles indent/whitespace markers; `Space Ts` toggles Sticky Scroll.

`Ctrl-d` / `Ctrl-u` animate half-page scrolling in roughly 120 ms, including
wrapped lines and folds. `Space TS` (uppercase `S`) toggles the animation; it is
disabled by default. Diff, floating/special buffers, large files, bound windows,
and macro recording/playback use native scrolling immediately.

Sticky Scroll is a syntax-and-indentation heuristic. It scans at most 1,000
lines or 256 KiB above the viewport. Unusual language syntax and complex
multiline declarations can still be missed.

## Native Space-key guide

Pressing `Space` in Normal mode opens a native guide for the available Space
key mappings. Buffer-local LSP and netrw mappings appear only when applicable.

- Continue typing to close the guide and run the selected mapping.
- `Esc`, `Ctrl-c`, or an unmapped key cancels it.
- Quickly completed mappings run without waiting for the guide.
- It does not intercept Visual, Insert, or Terminal mode.

## Files and buffers

| Key                    | Action                                                    |
| ---------------------- | --------------------------------------------------------- |
| `Space f`              | Fuzzy-find project files                                  |
| `Space Enter`          | Find Git-tracked files                                    |
| `Space e`              | Toggle the project tree and reveal the current file       |
| `Space sb`             | Select an open buffer                                     |
| `Space sr`             | Select a recent file                                      |
| `Space sn`             | Find Neovim configuration files                           |
| `Shift-h/l`, `[b`/`]b` | Previous/next buffer                                      |
| `Space bj/bk`          | Move the current buffer in the tabline                    |
| `Space bD/bL`          | Sort buffers by directory/filetype                        |
| `Space bp`             | Select a buffer                                           |
| `Space bw`             | Close the current buffer while protecting unsaved changes |
| `Space c`              | Force-close the current buffer                            |
| `Space bm`, `Space be` | Close other safe buffers                                  |
| `Space bh/bl`          | Close safe buffers to the left/right                      |

These buffer-close mappings preserve split windows and their sizes while multiple
buffers remain. When only one buffer remains, its duplicate editor panes in the
current tab merge into one; sidebars, floats, and other tabs are preserved.
Closing the last buffer leaves an empty buffer.

The Git root is the preferred project root. Without Git, the configuration
searches upward for CMake, Make, package.json, Python, Cargo, Bazel, and Buf
project markers. The editor cwd, tree, search, LSP, and ctags share this root.
For installed Python libraries, the top-level package under `site-packages` or
`dist-packages` is the root (for example, `site-packages/tvm`). Git discovery
stops at that package boundary, so a parent Homebrew or project repository is
not used. Git repositories inside the package are still recognized. A standalone
module directly in `site-packages` or `dist-packages` uses that directory instead.
Python standard-library files use the directory containing both `os.py` and
`importlib/__init__.py` (for example, `lib/python3.13`). Installed packages take
precedence over this enclosing standard-library root; neither crosses into a
parent repository.

### netrw tree

`Space e` opens netrw on the left and reuses its state within the same project.

| Key              | Action                                             |
| ---------------- | -------------------------------------------------- |
| `Enter`, `l`     | Expand/collapse a directory or open a file         |
| `h`              | Collapse the parent branch                         |
| `-`              | Go to the parent directory                         |
| `o`, `v`, `t`    | Open in a horizontal split, vertical split, or tab |
| `p`              | Preview a file                                     |
| `Space nr`       | Refresh the tree                                   |
| `gh`             | Toggle hidden files                                |
| `Space nh`       | Edit hidden-file patterns                          |
| `%`, `d`         | Create a file/directory                            |
| `R`, `D`         | Rename/delete                                      |
| `mf`, `mu`       | Mark files/clear all marks                         |
| `mt`, `mc`, `mm` | Set a target, then copy/move                       |
| `g?`             | Show complete netrw help                           |

`%` opens the new file in the first editor pane of the current tab and keeps the
tree open. If only the tree is open, an editor pane is created next to it.

The tree margin displays the two-character Git index/worktree state. `.M` is a
saved modification, `M.` is a staged modification, `??` is untracked, and `**`
marks a directory containing mixed states.

## Search and picker UI

A shared native picker provides an input box, result list, and preview without Telescope.

| Key        | Action                                          |
| ---------- | ----------------------------------------------- |
| `Space st` | Live project regex search                       |
| `Space t`  | Search for the cursor word, then filter results |
| `Space s/` | Search the saved on-disk contents of open files |
| `Space sc` | Find commands                                   |
| `Space sh` | Find help tags                                  |
| `Space sk` | Find current keymaps                            |
| `Space sp` | Preview and select a colorscheme                |
| `Space sd` | Find all diagnostics                            |

In a picker, use `Ctrl-n/p` or `Tab/Shift-Tab` to select, `Enter` to apply,
`Esc` to cancel, and `Ctrl-q` to export results to quickfix. Search prefers `rg`
and falls back to `grep` or `find`.

## Git

Git features never run network commands. Unsaved changes are compared with the
index and shown as `+`, `~`, and `-` signs in the margin.

| Key           | Action                                                                      |
| ------------- | --------------------------------------------------------------------------- |
| `Space gg`    | Open lazygit in a 90% × 90% float; otherwise show native Git status                                |
| `Space sg`    | Browse recent commits                                                       |
| `Space gd`    | Editable current file beside the index; `:q` in either pane closes the diff |
| `Space gD`    | Editable current file beside HEAD; `:q` in either pane closes the diff      |
| `Space gn/gp` | Move to the next/previous change hunk, wrapping at the ends                 |
| `Space gb`    | Toggle inline blame for the current line                                    |

Inline blame shows the author, date, and commit subject at the end of the current
line after 150 ms of inactivity. It hides during unsaved edits to avoid incorrect
line attribution and returns after saving. It is disabled for large files.

Additional editing actions use the same keys as pack:

| Key | Action |
| --- | --- |
| `Space gs/gr` | Stage/reset the cursor hunk or selected Visual lines |
| `Space gS/gR` | Stage/reset the whole buffer |
| `Space gU` | Undo the last staging action in this buffer |
| `Space gv` | Inline hunk preview; clear on cursor movement or editing |
| `Space gt` | Toggle deleted lines |
| `Space gB` | Full blame with commit details |
| `ih` | Hunk text object, including `vih` and `dih` |

Staging includes unsaved edits; reset changes the buffer against the index without
writing the file. Staging undo refuses to overwrite intervening changes to the
same index file entry. Hunk actions support regular UTF-8 text files up to 256 KiB;
conflicted index entries and binary files are rejected. Once an index write begins,
`:NopackCancel` lets it finish so Git can release its lock normally.

## LSP, completion, and diagnostics

Only configured servers whose executables can be found are started. Executables
are searched in this order:

1. the current `PATH`
2. an existing `stdpath("data")/mason/bin`

Mason is never loaded and no tool is installed automatically.

| Language                      | Server                                                       |
| ----------------------------- | ------------------------------------------------------------ |
| C/C++/Objective-C/CUDA        | `clangd`                                                     |
| MLIR                          | `mlir-lsp-server`                                            |
| Python                        | `ty server`, falling back to `pyright-langserver`            |
| Lua                           | `lua-language-server`                                        |
| JavaScript/TypeScript/JSX/TSX | `typescript-language-server`                                 |
| HTML                          | `vscode-html-language-server`                                |
| CSS/SCSS/Less                 | `vscode-css-language-server`                                 |
| Bazel/Starlark                | `starpls server`                                             |
| Protocol Buffers              | `buf lsp serve`                                              |
| Shell                         | `bash-language-server start`                                 |
| CMake                         | `neocmakelsp stdio`, falling back to `cmake-language-server` |
| YAML                          | `yaml-language-server`                                       |
| TeX                           | `texlab`                                                     |
| Rust                          | `rust-analyzer`                                              |
| Web auxiliaries               | Tailwind, Svelte, GraphQL, Emmet, Prisma, ESLint             |

Tailwind and ESLint attach only when project configuration or dependencies are
present. Emmet requires a project marker. An arbitrary executable for an unknown
language is not attached automatically.

| Key                | Action                                                  |
| ------------------ | ------------------------------------------------------- |
| `Ctrl-Space`       | Request completion manually in Insert mode              |
| `Ctrl-n/p`         | Select completion candidates                            |
| `Enter`            | Confirm a selected candidate or insert a normal newline |
| `Tab`, `Shift-Tab` | Move through snippet stops or candidates                |
| `gd`               | LSP definition, then ctags fallback                     |
| `gr`, `gD`, `K`    | References, declaration, hover documentation            |
| `gR`, `gi`, `gt`   | References/implementation/type-definition picker        |
| `Space la/lr`      | Code action/rename                                      |
| `Space ls`         | Restart LSP clients attached to this buffer             |
| `Space lv`         | Select a Python analysis environment                    |
| `[d`, `]d`         | Previous/next diagnostic                                |
| `Space ld/lD/sd`   | Line/buffer/all diagnostics                             |
| `Space lt`         | Toggle diagnostic display                               |
| `Space o`          | LSP or ctags code outline                               |

Without LSP, built-in completion uses words from the current and open buffers
plus ctags symbols. When supported ctags is installed, `gd` and the outline fall
back to saved sources in languages supported by the installed ctags. Use `:checkhealth vim.lsp` to inspect LSP state.

The outline and editor track each other without moving focus or requesting symbols on cursor movement. LSP tracking selects the innermost enclosing symbol; ctags tracking uses the nearest preceding declaration because it has no scope ranges.

## Formatting

`Space lf` formats the unsaved current buffer asynchronously. External output is
compared with `vim.text.diff()` and only changed ranges are applied, as one undo
step. Results are discarded if the buffer changes or closes while formatting.

| Filetype                           | External formatter                     |
| ---------------------------------- | -------------------------------------- |
| Lua                                | `stylua`                               |
| C/C++/CUDA                         | `clang-format`                         |
| Python                             | `ruff format`, falling back to `black` |
| JS/TS/JSX/TSX, HTML, CSS/SCSS/Less | `prettier`                             |
| JSON/JSONC, YAML, Markdown/MDX     | `prettier`                             |
| GraphQL, Vue, Handlebars           | `prettier`                             |
| Bazel/Starlark                     | `buildifier`                           |
| Protocol Buffers                   | `clang-format`                         |
| Shell                              | `shfmt`                                |
| CMake                              | `cmake-format`                         |
| TeX                                | `latexindent`                          |
| Rust                               | `rustfmt`                              |

If no registered external formatter exists, an attached LSP with document
formatting support is used. No external formatter is registered for MLIR or
Zsh. Format-on-save and range formatting are disabled.

## Undo, sessions, and terminal

Pack and Nopack share persistent undo at
`${XDG_STATE_HOME:-$HOME/.local/state}/nvim/undo`. Saved file history remains
available when switching modes; live editing sessions do not merge their undo trees.

| Key                | Action                                             |
| ------------------ | -------------------------------------------------- |
| `Space u`          | Preview undo states and apply the selected state   |
| `Space pr`         | Restore the current project session                |
| `Space pl`         | Restore the last session                           |
| `Space pS`         | Select a saved session                             |
| `Space pd`         | Stop saving the session for this run               |
| `Ctrl-t`           | Toggle a reusable shell terminal in a bottom split |
| Terminal `Esc Esc` | Leave Terminal mode                                |

Pack and Nopack share sessions at
`${XDG_STATE_HOME:-$HOME/.local/state}/nvim/sessions`, one per working directory.
Sessions preserve named editing files, cursor positions, cwd, splits, and tabs.
Explorer, help, floating windows, terminals, folds, and profile options are not
restored. Existing sessions in the old Nopack directory remain untouched. Sessions
are not backups of unsaved file contents. The last editor to save a project wins.

## Editing conveniences

- Automatic pairs for brackets, braces, quotes, and backticks
- Backspace deletes both characters of an empty pair
- `jk` leaves Insert mode
- `Ctrl-s` saves
- `Alt-j/k` moves the current line or Visual selection
- `Ctrl-h/j/k/l` moves between windows
- Shift-arrow keys resize windows
- Next/previous search results remain centered
- Visual indentation preserves the selection
- `Ctrl-t` reuses its terminal buffer
- Yank highlighting and OSC52 copy over SSH

Local Windows, macOS, and Linux sessions use `unnamedplus` with Neovim's desktop
clipboard provider. Over SSH, `yy` and Visual `y` send text to the client terminal
via OSC52 (which the terminal must support and allow); `p` uses the local register
without requesting clipboard access. Paste text from other applications using
the terminal's paste shortcut.

## Performance and safety limits

| Area                      | Limit                                           |
| ------------------------- | ----------------------------------------------- |
| General external commands | 5 seconds and 2 MiB stdout by default           |
| File/search candidates    | 10,000                                          |
| Displayed results         | 200                                             |
| File preview              | First 64 KiB                                    |
| Git signs                 | 256 KiB, 20,000 lines, 2,000 signs              |
| Formatting                | Files up to 2 MiB                               |
| Sticky Scroll             | 1,000 preceding lines, 256 KiB                  |
| Large-file protection     | Over 2 MiB, 50,000 lines, or a 10,000-byte line |
| SSH OSC52 copy            | Over 100,000 bytes is skipped with a warning    |

Large files disable LSP, syntax, completion, ctags, Git signs, Sticky Scroll,
formatting, wrapping, and cursor crosshair highlighting. `:NopackCancel` cancels
running search, Git, and ctags jobs plus scheduled refreshes.

## Deliberately unsupported

- Automatic plugin, LSP, or formatter download and updates
- `todo-comments.nvim`-style TODO/FIXME highlighting
- External colorscheme collections
- Neovide-specific font and zoom controls
- Debug Adapter Protocol (DAP)
- Automatic Treesitter parser installation

These are outside the nopack configuration's scope because they add network
dependencies, platform-specific behavior, worktree mutation, or maintenance cost.

## Tool setup and server transfer

Install only the executables needed for the languages listed above. FLASH never
installs tools. Shell aliases do not count as executables; use real files,
symlinks, or launchers. Each configured candidate is searched in PATH, then the
existing Mason bin directory: for example, ty in Mason still wins over Pyright
in PATH. The installer shares pack's Mason tools with FLASH without loading Mason.

A portable layout is `~/.local/opt/nvim-tools/`, with `node-tools/`, `python/`,
`llvm/`, and `lua-language-server/` below it. Put standalone binaries or launchers
in `~/.local/bin`. Add the required executable directories to PATH:

```sh
# Bash / Zsh
export PATH="$HOME/.local/bin:$HOME/.local/opt/nvim-tools/node-tools/node_modules/.bin:$HOME/.local/opt/nvim-tools/python/bin:$PATH"
```

```csh
# Csh / Tcsh
setenv PATH "$HOME/.local/bin:$HOME/.local/opt/nvim-tools/node-tools/node_modules/.bin:$HOME/.local/opt/nvim-tools/python/bin:$PATH"
```

Add LLVM, StyLua, or a separately unpacked Node runtime's `bin` directory when
needed, then start Neovim from that shell. A running editor does not inherit
later changes to its parent shell's PATH.

### Preparing tools

Python defaults to ty and Ruff. Put compatible `ty` and `ruff` executables in
PATH. Pyright and Black are alternatives; Node.js is required for Pyright:

```sh
npm install --prefix "$HOME/.local/opt/nvim-tools/node-tools" --save-exact pyright
python3 -m venv "$HOME/.local/opt/nvim-tools/python"
"$HOME/.local/opt/nvim-tools/python/bin/python" -m pip install black
```

For web development, install `typescript-language-server` together with a
compatible `typescript` version, `vscode-langservers-extracted`, and `prettier`
in that Node tools directory. Preserve the generated lock file and choose
versions compatible with the target Node runtime. `tsserver` found in PATH or
Mason is supplied as `tsserver.fallbackPath`; the language server also handles
project/bundled TypeScript discovery. Copying only the language-server executable
is insufficient. Project `node_modules/.bin` is not searched automatically.

Other web server package names:

| Executable | npm package |
| --- | --- |
| `tailwindcss-language-server` | `@tailwindcss/language-server` |
| `svelteserver` | `svelte-language-server` |
| `graphql-lsp` | `graphql-language-service-cli` |
| `emmet-ls` | `emmet-ls` |
| `prisma-language-server` | `@prisma/language-server` |
| `vscode-eslint-language-server` | `vscode-langservers-extracted` |

For C/C++/CUDA, install both clangd and clang-format. Preserve LLVM's distribution
layout, including libraries. Accurate analysis needs project compilation flags;
CMake can produce them with `cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`.
LuaLS also needs its complete distribution, including `main.lua` and resources;
keep it intact and expose its launcher through PATH. StyLua is a separate tool.

### Network-isolated servers

Copy **`init.lua` and its adjacent `lua/` directory together** into
`~/.config/nvim/`, or run `nvim -u /path/to/init.lua`. No plugin directory or pack
lock file is needed for FLASH. Tool binaries must match the server's OS, CPU,
libc, and runtime requirements; macOS binaries and virtual environments cannot
be reused on Linux.

Transfer Node tools as a complete directory, preserving symlinks and dependencies:

```sh
# Connected preparation machine with a compatible platform/runtime
tar -czf nvim-node-tools.tar.gz -C "$HOME/.local/opt/nvim-tools" node-tools
# After transferring the archive to the server
mkdir -p "$HOME/.local/opt/nvim-tools"
tar -xzf nvim-node-tools.tar.gz -C "$HOME/.local/opt/nvim-tools"
```

Node.js must also be available on the server. Do not copy only `.bin` or run
`npm install` on a server without access to the registry. Keep LuaLS and LLVM
bundles intact too. For Python tools, download wheels and their dependencies
in a compatible environment, then create a fresh venv on the server:

```sh
# Connected machine; transfer wheelhouse/ to the server afterwards
python3 -m pip download --only-binary=:all: --dest wheelhouse black
# Server
python3 -m venv "$HOME/.local/opt/nvim-tools/python"
"$HOME/.local/opt/nvim-tools/python/bin/python" -m pip install --no-index --find-links=wheelhouse black
```

### Python environments and troubleshooting

`Space lv` selects the project's analysis environment: `.venv`, `venv`, active
virtualenv/Conda, PATH Python, discovered Conda environments, or a manually entered
environment directory/Python executable. `Automatic` resets the choice. Selection
lasts for this Neovim run and affects analysis, not the shell or formatter PATH.
Ty restarts affected project clients when the environment changes; Pyright receives
its Python path setting. Project Pyright venv configuration can override it.

If tools are missing, restart Neovim after installing them and check:

```vim
:messages
:set filetype?
:checkhealth vim.lsp
:lua vim.print(vim.lsp.get_clients({bufnr=0}))
:lua print(vim.fn.exepath('ty'))
:lua print(vim.fn.stdpath('data') .. '/mason/bin')
```

`exepath()` checks PATH only, not FLASH's Mason fallback. A connected server can
still report import errors if the selected Python environment lacks dependencies.
Large-file protection also deliberately disables LSP and formatting.

## Ctags fallback

Universal Ctags is preferred; Exuberant Ctags is supported. BSD/Emacs ctags is not.
Check `ctags --version`. To select a binary explicitly:

```sh
nvim --cmd "let g:nopack_ctags='/path/to/ctags'"
```

| Key / command | Action |
| --- | --- |
| `gd` | Try LSP, then ctags; build the project index on first fallback |
| `g Ctrl-t` | Return through the tag stack |
| `:CtagsUpdate` | Rebuild the current project's index |
| `:CtagsClearAll` | Delete all managed project tag caches |
| `:NopackCancel` | Cancel jobs and pending refreshes |

Completion without an LSP and the ctags outline index the current file on demand.
Used project indexes update saved files after a 750 ms debounce; external file
changes require `:CtagsUpdate`. Git projects include tracked and non-ignored
untracked files. Caches live in `stdpath('data')/nopack/tags/`; `:setlocal tags?`
shows attached tag files. Full indexing is limited to 120 seconds/64 MiB and
file updates to 10 seconds/16 MiB. Ctags indexes saved names and positions;
it cannot replace semantic type analysis or track unsaved changes accurately.

## Configuration structure

The [entry point](../nvim/.config/nvim/init.lua) loads adjacent
[feature modules](../nvim/.config/nvim/lua/) in explicit dependency order.
It resolves symlinks and keeps the runtime isolated from pack modules/plugins.

| Owner | Responsibility |
| --- | --- |
| `options`, `keymaps`, `theme` | Runtime, settings, editing keys, appearance |
| `buffer_policy`, `bigfile` | Source/editor classification and analysis eligibility |
| `project`, `jobs`, `state` | Roots, cancellable work, shared interfaces/state |
| `explorer`, `navigation`, `buffers` | Tree, editor targets, buffer lifecycle |
| `pickers`, `search`, `editing` | Search UI, results, undo preview |
| `git`, `git_actions` | Status, signs, diff, blame, staging and hunk actions |
| `lsp`, `tags`, `completion`, `format`, `diagnostics` | Language tools and editing assistance |
| `outline`, `breadcrumb_symbols`, `breadcrumbs`, `context` | Cached symbols, outline, context navigation |
| `dashboard`, `terminal`, `session` | Auxiliary UI and session lifecycle |
| `statusline`, `indent`, `syntax`, `whichkey` | Native display and key guide |

Feature-private state stays local; shared interfaces live in `state.lua`, with
implementations owned by their feature. `buffer_policy.lua` distinguishes editable
source buffers from analysis-eligible buffers and auxiliary windows. Async work
checks eligibility before starting and applying results. `NopackBufferRestricted`
notifies features to cancel requests and clean up their UI; LSP detachment belongs
to `lsp.lua`, not the large-file detector. Project invalidation and process
cancellation belong to `project.lua` and `jobs.lua`. To investigate performance,
inspect the owning feature's events and callbacks, not just its file size.

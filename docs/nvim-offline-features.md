# Native Offline Neovim Features

[English](nvim-offline-features.md) | [한국어](nvim-offline-features.ko.md)

`init.offline.lua` is a **package-free, native Neovim configuration** built as a
single Lua file for Neovim 0.12+. It has no plugin manager, no external Lua
plugins, and no parser download step. It uses only Neovim's built-in APIs,
bundled runtime, and system commands that are already installed.

LSP servers and formatters are optional executables. The configuration detects
the tools it knows about but never downloads, installs, or updates them.

- Configuration: `nvim/.config/nvim/init.offline.lua`
- Required version: Neovim 0.12 or newer
- Implementation details and limits: [Offline Neovim 0.12](nvim-offline.md)
- Preparing optional tools: [LSP and formatter setup](nvim-offline-tools.md)

## Starting Neovim and the dashboard

```sh
nvim -u ~/.config/nvim/init.offline.lua
```

Starting without a file opens a native dashboard. Move with `j/k` or the arrow
keys and press `Enter`. The cursor stays on selectable rows.

| Key | Action |
| --- | --- |
| `f` | Find project files |
| `r` | Open recent files |
| `p` | Select a saved session |
| `n` | Create a new file |
| `c` | Open the active Neovim configuration |
| `q` | Quit |
| `Space A` | Reopen the dashboard while editing |

Passing a file argument skips the dashboard and opens that file directly.

## Interface

### Status line

The left side shows the Git branch and state followed by the filename. The
right side shows diagnostics, LSP and formatter availability, filetype, and a
fixed-width cursor position.

```text
[git:master .M] file.lua [+]    Warn 2 Error 1 [LSP O: lua_ls] [FORMAT O: stylua] lua |  123:  8 |  42%
```

- Diagnostic groups with a count of zero are hidden.
- `[LSP X]` has a highlighted background when no LSP is attached.
- `[FORMAT X]` means no formatter is currently available.
- `[FORMAT O: name]` names the external formatter or LSP used for this buffer.
- `Space Tl` toggles both the LSP and formatter status sections.

### Buffers, indent guides, and Sticky Scroll

- The native tabline displays open buffers and modified state.
- `Alt-1..8` selects that numbered buffer; `Alt-9` selects the last buffer.
- Indent guides use `┊` and follow the file's `shiftwidth`.
- Sticky Scroll keeps up to five enclosing function, conditional, and loop lines.
- Sticky rows preserve real line numbers, indentation, syntax highlighting, and a separator.
- `Space Ti` toggles indent/whitespace markers; `Space Ts` toggles Sticky Scroll.

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

| Key | Action |
| --- | --- |
| `Space f` | Fuzzy-find project files |
| `Space Enter` | Find Git-tracked files |
| `Space e` | Toggle the project tree and reveal the current file |
| `Space sb` | Select an open buffer |
| `Space sr` | Select a recent file |
| `Space sn` | Find Neovim configuration files |
| `Shift-h/l`, `[b`/`]b` | Previous/next buffer |
| `Space bj/bk` | Move the current buffer in the tabline |
| `Space bD/bL` | Sort buffers by directory/filetype |
| `Space bp` | Select a buffer |
| `Space bw` | Close the current buffer while protecting unsaved changes |
| `Space c` | Force-close the current buffer |
| `Space bm`, `Space be` | Close other safe buffers |
| `Space bh/bl` | Close safe buffers to the left/right |

The Git root is the preferred project root. Without Git, the configuration
searches upward for CMake, Make, package.json, Python, Cargo, Bazel, and Buf
project markers. The editor cwd, tree, search, LSP, and ctags share this root.

### netrw tree

`Space e` opens netrw on the left and reuses its state within the same project.

| Key | Action |
| --- | --- |
| `Enter`, `l` | Expand/collapse a directory or open a file |
| `h` | Collapse the parent branch |
| `-` | Go to the parent directory |
| `o`, `v`, `t` | Open in a horizontal split, vertical split, or tab |
| `p` | Preview a file |
| `Space nr` | Refresh the tree |
| `gh` | Toggle hidden files |
| `Space nh` | Edit hidden-file patterns |
| `%`, `d` | Create a file/directory |
| `R`, `D` | Rename/delete |
| `mf`, `mu` | Mark files/clear all marks |
| `mt`, `mc`, `mm` | Set a target, then copy/move |
| `g?` | Show complete netrw help |

The tree margin displays the two-character Git index/worktree state. `.M` is a
saved modification, `M.` is a staged modification, `??` is untracked, and `**`
marks a directory containing mixed states.

## Search and picker UI

A shared native picker provides an input box, result list, and preview without Telescope.

| Key | Action |
| --- | --- |
| `Space st` | Live project regex search |
| `Space t` | Search for the cursor word, then filter results |
| `Space s/` | Search the saved on-disk contents of open files |
| `Space sc` | Find commands |
| `Space sh` | Find help tags |
| `Space sk` | Find current keymaps |
| `Space sp` | Preview and select a colorscheme |
| `Space sd` | Find all diagnostics |

In a picker, use `Ctrl-n/p` or `Tab/Shift-Tab` to select, `Enter` to apply,
`Esc` to cancel, and `Ctrl-q` to export results to quickfix. Search prefers `rg`
and falls back to `grep` or `find`.

## Git

Git features never run network commands. Unsaved changes are compared with the
index and shown as `+`, `~`, and `-` signs in the margin.

| Key | Action |
| --- | --- |
| `Space gg` | Show Git status in a read-only bottom window |
| `Space sg` | Browse recent commits |
| `Space gd` | Side-by-side diff of the current file and index |
| `Space gD` | Side-by-side diff of the current file and HEAD |
| `Space gn/gp` | Move to the next/previous change hunk, wrapping at the ends |
| `Space gb` | Toggle inline blame for the current line |

Inline blame shows the author, date, and commit subject at the end of the current
line after 150 ms of inactivity. It hides during unsaved edits to avoid incorrect
line attribution and returns after saving. It is disabled for large files.

Mutating Git operations are deliberately absent: hunk stage/reset/undo, buffer
stage/reset, deleted-line restoration, and hunk text objects. Offline Git support
focuses on inspection and navigation without changing the worktree or index.

## LSP, completion, and diagnostics

Only configured servers whose executables can be found are started. Executables
are searched in this order:

1. `~/.config/nvim/lsp/bin`
2. the current `PATH`
3. an existing `stdpath("data")/mason/bin`

Mason is never loaded and no tool is installed automatically.

| Language | Server |
| --- | --- |
| C/C++/Objective-C/CUDA | `clangd` |
| MLIR | `mlir-lsp-server` |
| Python | `ty server`, falling back to `pyright-langserver` |
| Lua | `lua-language-server` |
| JavaScript/TypeScript/JSX/TSX | `typescript-language-server` |
| HTML | `vscode-html-language-server` |
| CSS/SCSS/Less | `vscode-css-language-server` |
| Bazel/Starlark | `starpls server` |
| Protocol Buffers | `buf lsp serve` |
| Shell | `bash-language-server start` |
| CMake | `neocmakelsp stdio`, falling back to `cmake-language-server` |
| YAML | `yaml-language-server` |
| TeX | `texlab` |
| Rust | `rust-analyzer` |
| Web auxiliaries | Tailwind, Svelte, GraphQL, Emmet, Prisma, ESLint |

Tailwind and ESLint attach only when project configuration or dependencies are
present. Emmet requires a project marker. An arbitrary executable for an unknown
language is not attached automatically.

| Key | Action |
| --- | --- |
| `Ctrl-Space` | Request completion manually in Insert mode |
| `Ctrl-n/p` | Select completion candidates |
| `Enter` | Confirm a selected candidate or insert a normal newline |
| `Tab`, `Shift-Tab` | Move through snippet stops or candidates |
| `gd` | LSP definition, then ctags fallback |
| `gr`, `gD`, `K` | References, declaration, hover documentation |
| `gR`, `gi`, `gt` | References/implementation/type-definition picker |
| `Space la/lr` | Code action/rename |
| `Space ls` | Restart LSP clients attached to this buffer |
| `Space lv` | Select a Python analysis environment |
| `[d`, `]d` | Previous/next diagnostic |
| `Space ld/lD/sd` | Line/buffer/all diagnostics |
| `Space lt` | Toggle diagnostic display |
| `Space Tr` | LSP or ctags code outline |

Without LSP, built-in completion uses words from the current and open buffers
plus ctags symbols. When supported ctags is installed, `gd` and the outline fall
back to saved C/C++ and Python sources. Use `:checkhealth vim.lsp` to inspect LSP state.

## Formatting

`Space lf` formats the unsaved current buffer asynchronously. External output is
compared with `vim.text.diff()` and only changed ranges are applied, as one undo
step. Results are discarded if the buffer changes or closes while formatting.

| Filetype | External formatter |
| --- | --- |
| Lua | `stylua` |
| C/C++/CUDA | `clang-format` |
| Python | `ruff format`, falling back to `black` |
| JS/TS/JSX/TSX, HTML, CSS/SCSS/Less | `prettier` |
| JSON/JSONC, YAML, Markdown/MDX | `prettier` |
| GraphQL, Vue, Handlebars | `prettier` |
| Bazel/Starlark | `buildifier` |
| Protocol Buffers | `clang-format` |
| Shell | `shfmt` |
| CMake | `cmake-format` |
| TeX | `latexindent` |
| Rust | `rustfmt` |

If no registered external formatter exists, an attached LSP with document
formatting support is used. No external formatter is registered for MLIR or
Zsh. Format-on-save and range formatting are disabled.

## Undo, sessions, and terminal

| Key | Action |
| --- | --- |
| `Space Tu` | Preview undo states and apply the selected state |
| `Space pr` | Restore the current project session |
| `Space pl` | Restore the last session |
| `Space pS` | Select a saved session |
| `Space pd` | Stop saving the session for this run |
| `Ctrl-t` | Toggle a reusable shell terminal in a bottom split |
| Terminal `Esc Esc` | Leave Terminal mode |

Sessions preserve buffers, cwd, windows, tabs, folds, and terminal state. They
are not backups of unsaved file contents.

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

## Performance and safety limits

| Area | Limit |
| --- | --- |
| General external commands | 5 seconds and 2 MiB stdout by default |
| File/search candidates | 10,000 |
| Displayed results | 200 |
| File preview | First 64 KiB |
| Git signs | 256 KiB, 20,000 lines, 2,000 signs |
| Formatting | Files up to 2 MiB |
| Sticky Scroll | 1,000 preceding lines, 256 KiB |
| Large-file protection | Over 2 MiB, 50,000 lines, or a 10,000-byte line |

Large files disable LSP, syntax, completion, ctags, Git signs, Sticky Scroll,
formatting, wrapping, and cursor crosshair highlighting. `:OfflineCancel` cancels
running search, Git, and ctags jobs plus scheduled refreshes.

## Deliberately unsupported

- Automatic plugin, LSP, or formatter download and updates
- Git hunk/buffer stage and reset
- `todo-comments.nvim`-style TODO/FIXME highlighting
- External colorscheme collections
- Neovide-specific font and zoom controls
- Debug Adapter Protocol (DAP)
- Automatic Treesitter parser installation
- Default `unnamedplus` system clipboard integration

These are outside the offline configuration's scope because they add network
dependencies, platform-specific behavior, worktree mutation, or maintenance cost.

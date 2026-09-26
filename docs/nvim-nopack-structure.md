# Nopack configuration structure

`nvim-nopack/.config/nvim-nopack/init.lua` loads feature modules directly from its
adjacent `lua/` directory. Initialization follows the previous single-file order.
These modules belong to the Nopack profile and never import Pack configuration
modules or third-party plugins.

Copy **both `init.lua` and `lua/`** when moving this configuration to a server.
The entry point resolves its real path, so symlinked profiles and direct
`nvim -u /path/to/init.lua` launches can find the adjacent modules. Only this
profile, Neovim's bundled runtime, and installed parser directories remain on
its runtime path; external package paths are still excluded.

| Module            | Responsibility                                                            |
| ----------------- | ------------------------------------------------------------------------- |
| `options.lua`     | Runtime isolation, compatibility APIs, editor options, tool lookup        |
| `keymaps.lua`     | Editing, window movement/resizing, clipboard hooks, common keymap helper  |
| `theme.lua`       | Built-in colorscheme and picker selection colors                          |
| `statusline.lua`  | Statusline rendering, diagnostics/LSP caches and highlights               |
| `indent.lua`      | Native indentation guides                                                 |
| `explorer.lua`    | Netrw options, file operations, sidebar sizing and help                   |
| `completion.lua`  | Native completion and snippets                                            |
| `navigation.lua`  | Tree toggle/reveal and choosing an editor window                          |
| `buffers.lua`     | Tabline, buffer picker, deletion and split preservation                   |
| `project.lua`     | Project/package roots, working-directory synchronization and invalidation |
| `jobs.lua`        | Async processes, cancellation and pending work                            |
| `pickers.lua`     | Result parsing, picker windows and location selection                     |
| `search.lua`      | File, command, metadata and text search                                   |
| `editing.lua`     | Undo browser and whitespace operations                                    |
| `terminal.lua`    | Reusable bottom terminal                                                  |
| `session.lua`     | Project session save/restore                                              |
| `dashboard.lua`   | Isolated native dashboard                                                 |
| `git.lua`         | Git status, Netrw status, diff, signs and inline blame                    |
| `format.lua`      | Formatter definitions, availability and asynchronous formatting           |
| `tags.lua`        | Ctags indexing, completion and definition fallback                        |
| `lsp.lua`         | Server definitions, Python environments, attach and enable lifecycle      |
| `outline.lua`     | LSP/ctags outline and refresh lifecycle                                   |
| `diagnostics.lua` | Diagnostic lists, navigation and toggle                                   |
| `bigfile.lua`     | Large-file detection and safeguards                                       |
| `syntax.lua`      | Bundled Treesitter parser or native syntax                                |
| `context.lua`     | Native sticky scroll                                                      |
| `whichkey.lua`    | Native Space-key guide                                                    |
| `state.lua`       | Shared functions and mutable state used by multiple feature modules       |

Each feature keeps its private functions and state local. Cross-module references
use the `shared` table from `state.lua`; their implementation stays in the owning
feature module. No module creates additional editor events merely to connect
features, and loading files does not introduce cursor-time polling.

To investigate performance, inspect the events and callbacks in the relevant
feature module. File splitting improves navigation through the code; it does not
make an expensive operation faster by itself.

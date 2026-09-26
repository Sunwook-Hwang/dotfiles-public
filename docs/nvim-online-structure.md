# Online configuration structure

`nvim/.config/nvim/init.online.lua` loads the feature modules directly from
`nvim/.config/nvim/lua/`, in the same order as the previous single-file setup.
It resolves its own file location, including symlinks, so `nvim -u /path/to/init.online.lua`
also works when the adjacent `lua/` directory is present.

`init.offline.lua` stays independent: it does not import any of these modules
and can still be copied alone. Online plugin packages and Mason tools are separate
from these configuration files and must also be available on an offline server.

| Module            | Responsibility                                                   |
| ----------------- | ---------------------------------------------------------------- |
| `options.lua`     | Disable defaults, editor options, leader                         |
| `keymaps.lua`     | Editing, window movement/resizing, cursor word highlight         |
| `bigfile.lua`     | Large-file safeguards and related events                         |
| `plugins.lua`     | `vim.pack` package registration                                  |
| `context.lua`     | Native sticky context and its update lifecycle                   |
| `ui.lua`          | Snacks setup: dashboard, indent, picker styling, terminal layout |
| `git.lua`         | Gitsigns, hunk operations, inline blame                          |
| `session.lua`     | Session persistence                                              |
| `clipboard.lua`   | SSH clipboard copying                                            |
| `whichkey.lua`    | Keybinding help                                                  |
| `pickers.lua`     | Search picker mappings                                           |
| `breadcrumbs.lua` | Dropbar sources and updates                                      |
| `outline.lua`     | Aerial outline and cursor tracking                               |
| `terminal.lua`    | Bottom terminal and lazygit toggles                              |
| `format.lua`      | Conform formatter registration and formatting                    |
| `completion.lua`  | Native completion and snippets                                   |
| `explorer.lua`    | Explorer root discovery and toggle                               |
| `lsp.lua`         | Native LSP, server definitions, Python environment, Mason        |
| `buffers.lua`     | Tabline, buffer selection and deletion                           |
| `statusline.lua`  | Statusline rendering and invalidation                            |
| `theme.lua`       | Final editor commands and colorscheme                            |

The only configuration module dependency is `ui.lua` importing the safeguard
function from `bigfile.lua`. Modules that use Snacks import the installed
`snacks` plugin directly. Configuration module names intentionally differ from
plugin entry points such as `snacks` and `dropbar`.

When investigating cursor lag, start with the events and callbacks in the relevant
feature module. File splitting does not itself change refresh frequency, introduce
lazy loading, or improve performance. Avoid re-sourcing individual modules during
a running session: their setup code registers mappings and events. Restart Neovim
after changes.

## 한국어

onvi는 `lua/` 바로 아래 기능 이름으로 파일을 분리했습니다. 진입점인
`init.online.lua`에 초기화 순서가 명시되어 있으며, 기존 실행 순서를 유지합니다.
다른 컴퓨터로 옮길 때는 `init.online.lua`와 옆의 `lua/` 디렉터리를 함께 복사해야 합니다.
플러그인과 Mason 도구는 별도로 준비해야 합니다.

offvi는 이 모듈들을 불러오지 않습니다. 기존처럼 `init.offline.lua` 하나만 가져가면 됩니다.
커서 지연을 조사할 때는 해당 기능 파일의 이벤트 등록과 갱신 콜백을 확인하면 됩니다.
이번 분리는 동작과 갱신 주기를 바꾸지 않습니다. 설정 변경 후에는 Neovim을 재시작하세요.

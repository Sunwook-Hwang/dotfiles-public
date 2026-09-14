# Offline Neovim 기능 안내

[English](nvim-offline-features.md) | [한국어](nvim-offline-features.ko.md)

`init.offline.lua`는 **패키지가 전혀 필요 없는 순수 Native Neovim 설정**입니다.
Neovim 0.12 내장 API와 시스템 명령만 사용하는 단일 Lua 파일로 구성되어 있습니다.
플러그인 매니저, 외부 Lua 플러그인, Treesitter 파서 다운로드 없이 실행할 수 있습니다.
LSP·포매터·Git·검색 도구는 설치되어 있을 때만 사용하며 자동으로 내려받지 않습니다.

- 설정 파일: `nvim/.config/nvim/init.offline.lua`
- 요구 버전: Neovim 0.12 이상
- English documentation: [Native Offline Neovim Features](nvim-offline-features.md)
- 상세 구현과 제한: [Offline Neovim 0.12](nvim-offline.md)
- 외부 도구 준비: [LSP·포맷터 설치 가이드](nvim-offline-tools.md)

## 실행과 시작 화면

```sh
nvim -u ~/.config/nvim/init.offline.lua
```

파일 인자 없이 실행하면 네이티브 dashboard가 열립니다. `j/k` 또는 방향키로 선택하고
`Enter`로 실행할 수 있으며, 커서는 선택 가능한 행에서만 움직입니다.

| 키 | 동작 |
| --- | --- |
| `f` | 프로젝트 파일 찾기 |
| `r` | 최근 파일 |
| `p` | 저장된 세션 선택 |
| `n` | 새 파일 |
| `c` | 현재 Neovim 설정 열기 |
| `q` | 종료 |
| `Space A` | 편집 중 dashboard 다시 열기 |

파일을 인자로 넘겨 실행하면 dashboard를 건너뛰고 바로 파일을 엽니다.

Dashboard는 전용 floating window를 사용합니다. `Esc`로 닫으면 기존 편집 창의
버퍼·커서·스크롤·창 옵션이 그대로 유지됩니다. 메뉴 선택과 직접 입력한 `:edit`는
원래 편집 창에서 파일을 엽니다.

## 화면 구성

### 상태줄

왼쪽에는 Git 브랜치와 현재 파일 상태, 파일명을 표시합니다. 오른쪽에는 진단 요약,
LSP·포매터 상태, 파일타입과 고정 폭 위치 정보를 표시합니다.

```text
[git:master .M] file.lua [+]    Warn 2 Error 1 [LSP: lua_ls] [FORMAT: stylua] lua |  123:  8 |  42%
```

- 진단 개수가 0이면 해당 항목을 숨깁니다.
- 연결된 LSP가 없으면 빨간 배경의 `[LSP X]`를 표시합니다.
- 사용할 포매터가 없으면 `[FORMAT X]`를 표시합니다.
- `[FORMAT: 이름]`은 현재 버퍼에서 실제 사용할 외부 도구 또는 LSP 이름입니다.
- `Space Tl`로 LSP와 포매터 상태 영역을 함께 숨기거나 다시 표시합니다.

### 버퍼·들여쓰기·Sticky Scroll

- 상단 tabline에 열린 버퍼와 수정 상태를 표시합니다.
- `Alt-1..8`은 해당 번호 버퍼, `Alt-9`는 마지막 버퍼로 이동합니다.
- 들여쓰기 선은 파일의 `shiftwidth`에 맞춰 `┊`로 표시합니다.
- Sticky Scroll은 함수·조건·반복문의 상위 문맥을 최대 8줄까지 고정합니다.
- Sticky 영역은 실제 줄 번호, 들여쓰기 위치, syntax highlight와 구분선을 유지합니다.
- `Space Ti`로 들여쓰기/공백 표시, `Space Ts`로 Sticky Scroll을 토글합니다.

Sticky Scroll은 들여쓰기와 기본 syntax를 이용한 휴리스틱입니다. 위쪽 1,000줄 또는
256 KiB까지만 탐색하며 복잡한 여러 줄 선언이나 특이한 언어 문법은 놓칠 수 있습니다.

## 단축키 찾기

Normal 모드에서 `Space`를 누르면 현재 사용 가능한 Space 단축키를 하단에 표시합니다.
LSP나 netrw처럼 버퍼에만 붙는 매핑도 현재 상태에 맞춰 반영합니다.

- 다음 키를 누르면 안내창을 닫고 해당 단축키를 실행합니다.
- `Esc`, `Ctrl-c` 또는 등록되지 않은 키로 취소합니다.
- 빠르게 완성한 Space 단축키는 안내창을 거치지 않고 바로 실행합니다.
- Visual·Insert·Terminal 모드에는 개입하지 않습니다.

## 파일과 버퍼

| 키 | 동작 |
| --- | --- |
| `Space f` | 프로젝트 파일 fuzzy picker |
| `Space Enter` | Git 추적 파일 picker |
| `Space e` | 프로젝트 트리 토글 및 현재 파일 위치 표시 |
| `Space sb` | 열린 버퍼 picker |
| `Space sr` | 최근 파일 picker |
| `Space sn` | Neovim 설정 파일 picker |
| `Shift-h/l`, `[b`/`]b` | 이전/다음 버퍼 |
| `Space bj/bk` | tabline에서 현재 버퍼 순서 이동 |
| `Space bD/bL` | 디렉터리/파일타입 기준 버퍼 정렬 |
| `Space bp` | 버퍼 선택 |
| `Space bw` | 미저장 변경을 보호하며 현재 버퍼 닫기 |
| `Space c` | 현재 버퍼 강제 닫기 |
| `Space bm`, `Space be` | 현재 버퍼 외의 안전한 버퍼 닫기 |
| `Space bh/bl` | 현재 버퍼 왼쪽/오른쪽의 안전한 버퍼 닫기 |

프로젝트 루트는 Git 루트를 우선합니다. Git이 없으면 CMake, Make, package.json,
Python, Cargo, Bazel, Buf 프로젝트 marker를 위쪽으로 찾습니다. 편집창 cwd, 파일 트리,
검색, LSP와 ctags가 같은 루트를 사용합니다.

### netrw 트리

`Space e`는 왼쪽 netrw 트리를 열고 같은 프로젝트에서는 기존 트리 상태를 재사용합니다.

| 키 | 동작 |
| --- | --- |
| `Enter`, `l` | 디렉터리 펼치기/접기 또는 파일 열기 |
| `h` | 상위 가지 접기 |
| `-` | 상위 디렉터리 |
| `o`, `v`, `t` | 가로 분할, 세로 분할, 탭으로 열기 |
| `p` | 파일 미리보기 |
| `Space nr` | 트리 새로고침 |
| `gh` | 숨김 파일 토글 |
| `Space nh` | 숨김 패턴 편집 |
| `%`, `d` | 파일/디렉터리 생성 |
| `R`, `D` | 이름 변경/삭제 |
| `mf`, `mu` | 파일 표시/표시 전체 해제 |
| `mt`, `mc`, `mm` | 대상 지정 후 복사/이동 |
| `g?` | 전체 netrw 키 도움말 |

트리 여백에는 Git의 index/worktree 상태를 두 글자로 표시합니다. 예를 들어 `.M`은
저장된 수정, `M.`은 staged 수정, `??`는 미추적 파일이며 혼합된 폴더는 `**`입니다.

## 검색과 선택 UI

외부 Telescope 없이 입력창, 결과 목록과 미리보기로 구성된 공통 picker를 사용합니다.

| 키 | 동작 |
| --- | --- |
| `Space st` | 프로젝트 live 정규식 검색 |
| `Space t` | 커서 단어 검색 후 결과 필터 |
| `Space s/` | 열린 파일의 저장된 디스크 내용 검색 |
| `Space sc` | 명령 검색 |
| `Space sh` | 도움말 검색 |
| `Space sk` | 현재 키맵 검색 |
| `Space sp` | colorscheme 미리보기와 선택 |
| `Space sd` | 전체 진단 검색 |

Picker에서는 `Ctrl-n/p` 또는 `Tab/Shift-Tab`으로 선택하고 `Enter`로 적용합니다.
`Esc`는 취소하고 `Ctrl-q`는 결과를 quickfix로 보냅니다. 검색은 `rg`를 우선하고 없으면
`grep` 또는 `find`를 사용합니다.

## Git

Git 기능은 네트워크 명령을 실행하지 않습니다. 현재 버퍼의 미저장 변경도 index와 비교해
여백에 추가 `+`, 수정 `~`, 삭제 `-` sign으로 표시합니다.

| 키 | 동작 |
| --- | --- |
| `Space gg` | Git 상태를 아래 읽기 전용 창에 표시 |
| `Space sg` | 최근 커밋 목록 |
| `Space gd` | 편집 가능한 현재 파일과 index 좌우 diff; 어느 창에서든 `:q`로 닫기 |
| `Space gD` | 편집 가능한 현재 파일과 HEAD 좌우 diff; 어느 창에서든 `:q`로 닫기 |
| `Space gn/gp` | 다음/이전 변경 hunk로 이동; 끝에서 순환 |
| `Space gb` | 현재 줄 inline blame 토글 |

Inline blame은 저장된 파일의 작성자, 날짜와 커밋 메시지를 현재 줄 끝에 표시합니다.
커서 이동 후 150ms 동안 입력이 없을 때 갱신하고, 미저장 편집 중에는 잘못된 줄 attribution을
피하기 위해 숨겼다가 저장 후 다시 표시합니다. 큰 파일에서는 실행하지 않습니다.

다음 Git 변경 기능은 제공하지 않습니다: hunk stage/reset/undo, buffer stage/reset,
삭제 줄 복원 표시, hunk text object. 작업 파일이나 index를 실수로 변경하지 않도록
현재 offline Git 기능은 조회와 탐색 중심입니다.

## LSP·완성·진단

실행 파일을 찾은 서버만 Neovim 내장 LSP로 시작합니다. 검색 순서는 다음과 같습니다.

1. 현재 `PATH`
2. 기존 `stdpath("data")/mason/bin`

Mason을 로드하거나 도구를 설치하지 않습니다. 현재 등록된 서버는 다음과 같습니다.

| 언어 | 서버 |
| --- | --- |
| C/C++/Objective-C/CUDA | `clangd` |
| MLIR | `mlir-lsp-server` |
| Python | `ty server`, 없으면 `pyright-langserver` |
| Lua | `lua-language-server` |
| JavaScript/TypeScript/JSX/TSX | `typescript-language-server` |
| HTML | `vscode-html-language-server` |
| CSS/SCSS/Less | `vscode-css-language-server` |
| Bazel/Starlark | `starpls server` |
| Protocol Buffers | `buf lsp serve` |
| Shell | `bash-language-server start` |
| CMake | `neocmakelsp stdio`, 없으면 `cmake-language-server` |
| YAML | `yaml-language-server` |
| TeX | `texlab` |
| Rust | `rust-analyzer` |
| Web 보조 서버 | Tailwind, Svelte, GraphQL, Emmet, Prisma, ESLint |

Tailwind·ESLint는 프로젝트 설정이나 dependency가 있을 때만 연결하고 Emmet은 설정 marker가
있을 때만 연결합니다. 임의의 실행 파일을 자동 탐지해 새 언어에 연결하지는 않습니다.

| 키 | 동작 |
| --- | --- |
| `Ctrl-Space` | Insert 모드 완성 후보 수동 요청 |
| `Ctrl-n/p` | 완성 후보 이동 |
| `Enter` | 선택 후보 확정 또는 일반 줄바꿈 |
| `Tab`, `Shift-Tab` | snippet 자리 또는 완성 후보 이동 |
| `gd` | LSP 정의, 실패하면 ctags 정의 |
| `gr`, `gD`, `K` | 참조, 선언, hover 문서 |
| `gR`, `gi`, `gt` | 참조/구현/타입 정의 결과 picker |
| `Space la/lr` | 코드 액션/이름 변경 |
| `Space ls` | 현재 버퍼 LSP 재시작 |
| `Space lv` | Python 분석 환경 선택 |
| `[d`, `]d` | 이전/다음 진단 |
| `Space ld/lD/sd` | 현재 줄/버퍼/전체 진단 보기 |
| `Space lt` | 진단 표시 토글 |
| `Space Tr` | LSP 또는 ctags 코드 아웃라인 |

LSP가 없으면 현재·열린 버퍼 단어와 ctags 심볼을 내장 완성에 사용합니다. `gd`와 코드
아웃라인도 지원되는 ctags가 있으면 저장된 C/C++·Python 소스를 대상으로 fallback합니다.

`:checkhealth vim.lsp`로 연결 상태를 확인할 수 있습니다.

## 포맷팅

`Space lf`는 저장하지 않은 현재 버퍼를 비동기로 포맷합니다. 외부 도구 결과를
`vim.text.diff()`로 비교해 변경 구간만 적용하고 한 번의 undo로 되돌릴 수 있게 합니다.
실행 중 버퍼가 바뀌거나 닫히면 늦게 도착한 결과를 버립니다.

| 파일타입 | 외부 포매터 |
| --- | --- |
| Lua | `stylua` |
| C/C++/CUDA | `clang-format` |
| Python | `ruff format`, 없으면 `black` |
| JS/TS/JSX/TSX, HTML, CSS/SCSS/Less | `prettier` |
| JSON/JSONC, YAML, Markdown/MDX | `prettier` |
| GraphQL, Vue, Handlebars | `prettier` |
| Bazel/Starlark | `buildifier` |
| Protocol Buffers | `clang-format` |
| Shell | `shfmt` |
| CMake | `cmake-format` |
| TeX | `latexindent` |
| Rust | `rustfmt` |

등록된 외부 포매터가 없으면 연결된 LSP의 document formatting을 시도합니다. MLIR과 Zsh는
외부 포매터를 등록하지 않았습니다. 저장 시 자동 포맷과 선택 영역 포맷은 사용하지 않습니다.

## Undo·세션·터미널

| 키 | 동작 |
| --- | --- |
| `Space Tu` | undo 상태 목록과 코드 미리보기; `Enter`로 선택 상태 적용 |
| `Space pr` | 현재 프로젝트 세션 복원 |
| `Space pl` | 마지막 세션 복원 |
| `Space pS` | 저장된 세션 선택 |
| `Space pd` | 현재 실행에서 세션 저장 중지 |
| `Ctrl-t` | 같은 shell terminal을 아래 split에서 토글 |
| Terminal `Esc Esc` | Terminal 모드 종료 |

세션은 버퍼, 작업 디렉터리, 창, 탭, fold와 terminal 상태를 저장하지만 미저장 파일 내용의
백업은 아닙니다.

## 편집 편의 기능

- 괄호, 대괄호, 중괄호, 따옴표와 백틱 자동 짝 맞추기
- 빈 쌍에서 Backspace를 누르면 두 문자 함께 삭제
- `jk`로 Insert 모드 종료
- `Ctrl-s`로 저장
- `Alt-j/k`로 현재 줄 또는 Visual 선택 이동
- `Ctrl-h/j/k/l`로 창 이동
- Shift 방향키로 창 크기 조절
- 검색 다음/이전 결과를 화면 중앙에 유지
- Visual 들여쓰기 후 선택 유지
- `Ctrl-t` terminal 버퍼 재사용
- yank highlight와 SSH 환경의 OSC52 복사

## 성능과 안전 제한

| 대상 | 제한 |
| --- | --- |
| 일반 외부 명령 | 기본 5초, stdout 2 MiB |
| 파일/검색 후보 | 최대 10,000개 |
| 화면 표시 결과 | 최대 200개 |
| 파일 미리보기 | 앞 64 KiB |
| Git sign | 256 KiB, 20,000줄, sign 2,000개 |
| 포맷팅 | 2 MiB 이하 파일 |
| Sticky Scroll | 위쪽 1,000줄, 256 KiB |
| 큰 파일 보호 | 2 MiB, 50,000줄 또는 한 줄 10,000바이트 초과 |

큰 파일에서는 LSP, syntax, 자동완성, ctags, Git sign, Sticky Scroll과 포맷팅을 중지하고
wrap과 커서 십자 강조도 끕니다. `:OfflineCancel`은 실행 중인 검색·Git·ctags 작업과 예약된
갱신을 취소합니다.

## 의도적으로 제공하지 않는 기능

- 플러그인·LSP·포매터 자동 다운로드 및 업데이트
- Git hunk/buffer stage와 reset
- `todo-comments.nvim` 방식의 TODO/FIXME 강조
- 외부 colorscheme 묶음
- Neovide 전용 글꼴·확대/축소 설정
- Debug Adapter Protocol(DAP)
- Treesitter parser 자동 설치
- 시스템 clipboard의 기본 `unnamedplus` 연결

이 기능들은 네트워크 의존성, 플랫폼 차이, 작업 내용 변경 위험 또는 유지 비용 때문에
offline 설정의 기본 범위에서 제외합니다.

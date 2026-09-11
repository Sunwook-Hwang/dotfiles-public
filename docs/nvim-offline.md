# Offline Neovim 0.12

서버에 필요한 설정 파일은 `nvim/.config/nvim/init.offline.lua` 하나입니다.
Neovim **0.12 이상**을 요구하며, 이전 버전에서는 명확한 오류를 표시합니다.
플러그인 매니저, 외부 플러그인 파일, 패키지/파서 다운로드는 사용하지 않습니다.

도구를 준비하려면 [LSP·포맷터 설치 위치, PATH 설정, 오프라인 서버 전송 가이드](nvim-offline-tools.md)를 참고하세요.

Stow 환경:

```sh
nvim -u ~/.config/nvim/init.offline.lua
```

서버에서는 이 파일을 전송한 경로로 `nvim -u /path/to/init.offline.lua`를 실행하거나,
기존 설정을 백업하고 `~/.config/nvim/init.lua`에 배치합니다.
플러그인 기반 기본 설정 `init.lua`와는 별개입니다.
LSP가 없거나 정의·심볼 요청이 실패하면 저장된 파일의 ctags 정보를 사용합니다.

## 0.12 내장 기능으로 변경한 부분

- LSP 연결: `vim.lsp.config()` / `vim.lsp.enable()`. 설치된 실행 파일만 활성화합니다.
- LSP 자동완성: `vim.lsp.completion.enable()`의 비동기 자동 팝업을 사용합니다.
  서버가 지정한 트리거 문자(예: `.`)에서만 자동 요청합니다. 일반 글자 입력을 강제로
  트리거에 추가하지 않으며, 필요할 때 `Ctrl-Space`로 요청할 수 있습니다.
- 문서: 후보 선택 시 서버가 제공하는 설명을 내장 popup에 표시합니다.
- 스니펫: 서버가 반환하는 snippet을 내장 `vim.snippet`으로 확장합니다.
  별도 사용자 스니펫 모음이나 LuaSnip은 없습니다.
- LSP 미연결 버퍼: `autocomplete`로 현재/열린 버퍼의 단어와 ctags 심볼을 자동 완성합니다.
  LSP 후보와 버퍼 단어를 하나로 합치는 Blink의 다중 소스 엔진은 아닙니다.
- 포맷팅: 외부 도구 결과를 `vim.text.diff()`로 비교하고 변경된 줄 구간만 적용합니다.
  변경 없는 줄의 extmark 위치를 유지하고 한 번의 undo로 포맷팅을 취소합니다.
- 프로젝트 탐색: `vim.fs.root/find`. Git 루트 우선, 없으면 가장 가까운 프로젝트 마커입니다.
  편집 창 cwd, 트리, 검색, LSP에 같은 기준을 적용합니다.
- 진단 이동: `vim.diagnostic.jump()`. 상태줄에 내장 진단 요약을 표시합니다.
- 터미널: `jobstart(..., {term=true})`. Git 줄 비교: `vim.text.diff()`.
- 구문 강조: Neovim 설치본에 포함된 파서가 있으면 내장 Treesitter를 켭니다.
  해당 언어 파서가 없으면 기본 syntax를 사용하며 설치를 시도하지 않습니다.

## 자동 짝 맞추기

일반 파일의 입력 모드에서 `(`, `[`, `{`, 작은따옴표, 큰따옴표, 백틱을 누르면
짝을 함께 넣고 커서를 사이에 둡니다. 닫는 문자 앞에서 같은 문자를 누르면 커서만
넘어가며, 빈 쌍 사이에서 Backspace를 누르면 둘 다 지웁니다.
이스케이프한 문자, 단어 바로 앞에 넣는 여는 문자, 단어 뒤의 작은따옴표는 그대로 입력합니다.
검색창과 큰 파일 보호가 켜진 버퍼에서는 생략합니다. `< >`는 비교 연산자 입력을 위해
자동 짝 맞추기 대상에서 제외합니다.

## 완성·LSP·포맷팅 키

| 키 | 동작 |
| --- | --- |
| 입력 중 자동 팝업 | 서버 지정 트리거의 LSP 후보 또는 LSP가 없으면 버퍼 단어·ctags 심볼 |
| Insert `Ctrl-Space` | 완성 후보 수동 요청 |
| `Ctrl-n/p` | 후보 이동 |
| `Enter` | 선택한 후보 확정; 선택이 없으면 줄바꿈 |
| `Tab` / `Shift-Tab` | 활성 스니펫의 다음/이전 자리, 없으면 후보 이동; 둘 다 없으면 원래 키 |
| `Ctrl-x Ctrl-f` | 내장 파일 경로 완성 |
| `gd`, `gr`, `gD`, `K` | 정의·참조·선언·도움말 |
| `gR`, `gi`, `gt` | 참조·구현·타입 정의 결과 picker |
| `Space la/lr` | 코드 액션 / 이름 변경 |
| `Space lv` | Python LSP 환경 선택: 프로젝트 .venv/venv, Conda 환경 목록, 활성 환경, PATH, 직접 경로 |
| `Space ls` | 현재 버퍼 LSP 재시작 (`:lsp restart`) |
| `Space ld/lD/sd` | 현재 줄 진단 / 버퍼 진단 picker / 전체 진단 picker |
| `[d`, `]d`, `Space lt` | 진단 이전·다음 / 진단 표시 토글 |
| `Space lf` | 수동 비동기 파일 전체 포맷팅 |
| `Space Tr` | 현재 파일의 함수·클래스 아웃라인 사이드바 토글 |

LSP는 등록 언어(C/C++, Python, Lua, JS/TS, HTML/CSS 등)의 실행 파일을
`~/.config/nvim/lsp/bin` → PATH → 기존 `stdpath("data")/mason/bin` 순서로 찾습니다.
어느 위치에도 실행 파일이 없으면 해당 서버를 활성화하지 않습니다.
Mason 플러그인 로드·도구 설치·PATH 변경은 하지 않습니다. `:checkhealth vim.lsp`로 확인할 수 있습니다. 서버별 응답 내용에 따라 완성·설명·
스니펫·자동 import의 지원 여부가 달라집니다.
Python LSP는 `ty server`를 우선하고, ty가 없을 때 `pyright-langserver`를 사용합니다.
보조 서버인 Tailwind와 ESLint는 프로젝트 설정 파일 또는 `package.json`의 해당 의존성이
있을 때만 연결합니다. Emmet은 `.emmet.json` 또는 `emmet.json`이 있을 때 연결합니다.

Python 파일에서 `Space lv`로 패키지가 설치된 가상환경/Conda 환경을 선택한 뒤,
import한 이름이나 함수 위에서 `gd`를 누르면 해당 환경의 패키지 정의로 이동합니다.
목록에 없으면 `Enter Python path...`에 `/path/to/env` 또는 `/path/to/env/bin/python`을 입력합니다.
ty에는 `ty.configuration.environment.python`으로 전달하며, 환경을 바꿀 때 해당 프로젝트의 ty만
자동 재시작해 패키지 검색 경로를 갱신합니다. 다른 프로젝트의 LSP와 열린 파일은 유지합니다.
같은 환경을 다시 선택하면 재시작하지 않습니다. Pyright는 설정 변경 알림으로 반영합니다.
선택은 Neovim을 닫기 전까지 프로젝트별로 유지되며, `Space ls`로 LSP를 재시작해도 유지됩니다.
`Automatic`을 선택하면 지정 경로를 해제하고 프로젝트 설정/상속된 환경의 자동 탐색으로 돌아갑니다.
이 선택은 분석 환경만 바꾸며 셸, 실행 명령, Ruff/Black의 PATH는 바꾸지 않습니다.
패키지가 선택한 환경에 설치되어 있어야 하며, Python 소스/타입 스텁이 없는 네이티브 모듈은
정의로 이동할 수 없는 경우가 있습니다.

외부 포맷터는 Lua `stylua`, C/C++ `clang-format`, Python `ruff format`(없으면 `black`),
JavaScript `prettier`입니다. 없으면 내장 LSP 포맷팅을 시도합니다.
저장 시 자동 포맷팅과 선택 영역 포맷팅은 켜지 않습니다.
외부 포맷팅 도중 버퍼가 바뀌거나 닫히면 결과를 버립니다. 작업은 버퍼별로 취소됩니다.

## 유지한 검색·탐색·편집 동작

기본 테마는 Neovim 내장 `retrobox`이며 syntax highlighting을 사용합니다.
현재 행과 줄 번호(`cursorlineopt=line,number`), 세로 열(`cursorcolumn`)을 함께 강조해 십자 커서를 표시합니다.
`lazyredraw`는 꺼두며 `Ctrl-d/u`는 내장 반 페이지 이동을 그대로 사용합니다.

| 키 | 동작 |
| --- | --- |
| `Space f` / `Space Enter` | 파일 / Git 추적 파일 fuzzy picker |
| `Space st` / `Space t` | live regex 검색 / 커서 단어 검색 후 결과 필터 |
| `Space s/` | 열린 파일의 저장된 내용 검색 |
| `Space sb/sr/sn` | 버퍼 / 최근 파일 / 설정 파일 picker |
| `Space sc/sh/sk/sp` | 명령 / 도움말 / 키맵 / 테마 picker |
| picker `Enter` / `Esc` / `Ctrl-q` | 선택 / 취소 / quickfix 내보내기 |
| `Space e` | Git 프로젝트 기준 netrw 트리 토글, 현재 파일 추적 |
| `Ctrl-h/j/k/l` | 창 이동, 트리에서도 동일 |
| `Shift-h/l`, `[b` / `]b` | 표시 순서의 이전/다음 버퍼 |
| `Space bj/bk`, `bD/bL` | 버퍼 재배열 / 디렉터리·언어별 정렬 |
| `Space bm` / `be` | 다른 목록 버퍼 닫기; 미저장 파일과 `Ctrl-t` 재사용 터미널은 유지 |
| `Space c` / `bw` | 강제 닫기(미저장 변경 버림) / 미저장 파일 보호하며 닫기 |
| `Ctrl-t` | `Space gg`와 같은 크기의 하단 split 터미널 토글 |
| 터미널 `Esc Esc` | Terminal 모드에서 Normal 모드로 이동 |
| `Space gd/gD` | 현재 파일과 index/HEAD를 좌우 비교 |
| `Space Tu` | undo 상태 목록과 코드 미리보기. `↑/↓`·`Ctrl-p/n` 선택, `Ctrl-f/b` 스크롤, Enter 적용, Esc 취소 |
| `Space Ti` | 들여쓰기 가이드·탭·후행 공백 표시 토글 (기본 켜짐) |
| `Space pr/pl/pS/pd` | 프로젝트 세션 복원 / 마지막 / 선택 / 저장 중지 |

Git 추적 파일의 저장 전 변경은 여백에 `+`, `~`, `-`로 표시합니다.
netrw 트리의 왼쪽 여백에는 저장된 Git 상태를 두 글자로 표시합니다. 첫 글자는 index,
둘째는 작업 파일 상태이며, `.`은 변경 없음입니다: `.M` 수정, `M.` 스테이징된 수정,
`A.` 스테이징된 추가, `??` 미추적 파일. 폴더는 하위 변경을 모아 표시하고 상태가 섞이면 `**`로 표시합니다.
저장·트리 새로고침(`Space nr`)·포커스/터미널 복귀 시 갱신하며, 폴더를 펼치거나 접을 때는
캐시로 표식을 즉시 맞춥니다. 전체 Git 상태 조회는 프로젝트별로 공유하며 최대 1초 간격으로 실행합니다.
같은 프로젝트의 파일로 이동할 때는 기존 트리를 재사용합니다. 미저장 편집과 무시된 파일은 이 Git 표시에 포함하지 않습니다.
혼합 구간에서 수정/추가의 구분은 내용 유사도에 따른 추정입니다.
들여쓰기 가이드는 내장 `listchars`로 파일의 `shiftwidth`에 맞춰 표시합니다. 탭도 세로선으로 표시하며, 빈 줄을 관통하는 선과 현재 범위 강조는 지원하지 않습니다.
Which-key 팝업, 시각적 Undotree, DAP는 추가하지 않았습니다.
0.12에서도 이들 플러그인 UI가 기본 제공되는 것은 아닙니다.

## 코드 아웃라인

`Space Tr`로 오른쪽 아웃라인을 열고 닫습니다. LSP 문서 심볼을 우선 사용하고,
서버가 없거나 요청이 실패·시간 초과·빈 결과이면 ctags로 저장된 파일의 심볼을 표시합니다.
함수·클래스·메서드 등을 종류와 이름으로 표시하고, 서버가 제공한 자식 심볼은 들여쓰기로 구분합니다.
계층 없는 목록을 반환하는 서버는 평면 목록으로 표시합니다.

- `j/k`로 항목 선택, `Enter`로 편집 창의 해당 위치로 이동
- `Ctrl-h/j/k/l`로 일반 창 이동
- `r`로 수동 새로고침, `q` 또는 `Space Tr`로 닫기
- 열린 동안 파일 전환·저장·LSP 연결 변경 시 갱신; 매 키 입력마다 요청하지 않음

현재 커서가 속한 심볼을 열기/갱신 시 선택합니다. Aerial의 전체 기능을 구현한 것은 아니며,
노드 접기·실시간 커서 추적·Treesitter 기반 심볼 추출은 없습니다. 여러 서버가 붙으면
심볼을 지원하는 첫 클라이언트를 사용합니다. ctags 결과는 저장된 파일이 바뀔 때 갱신합니다.

## Ctags fallback

C/C++·Python의 정의 이동·완성·아웃라인은 **Universal Ctags 또는 Exuberant Ctags**를
사용할 수 있습니다. BSD/Emacs ctags는 지원하지 않습니다. 버전 확인은 비동기로 실행하며,
실행 파일 후보 중 Universal Ctags를 우선합니다. 도구는 자동으로 설치하지 않습니다.

```sh
ctags --version
nvim --cmd "let g:offline_ctags='/path/to/ctags'" -u ~/.config/nvim/init.offline.lua
```

직접 지정하지 않으면 PATH에서 찾습니다. 서버에 복사하는 실행 파일은 서버의 OS·CPU와
호환되어야 합니다. ctags는 타입 분석이 아닌 저장된 소스의 이름·위치 정보입니다.

| 키/명령 | 동작 |
| --- | --- |
| `gd` | LSP 정의 요청이 없거나 실패하면 ctags로 이동; 첫 fallback에서 프로젝트 인덱스 생성 |
| `g Ctrl-t` | ctags 태그 스택에서 이전 위치로 복귀 |
| `:CtagsUpdate` | 현재 프로젝트 전체 인덱스 재생성 |
| `:CtagsClearAll` | 관리하는 모든 프로젝트 ctags 캐시 삭제 |
| `:OfflineCancel` | 실행 중인 명령·예약된 태그 갱신·검색창 취소 |

- LSP 완성 제공자가 없을 때 첫 입력 모드 진입은 현재 파일을 인덱싱합니다.
- ctags 아웃라인도 현재 파일을 인덱싱하며, 변경되지 않은 결과는 재사용합니다.
- 인덱스를 사용한 프로젝트는 저장 후 750ms 동안 변경을 모아 해당 파일의 태그를 교체합니다.
- 태그 병합·정렬·파일 쓰기는 내장 작업 스레드에서 실행합니다. 취소·실패한 결과는 게시하지 않습니다.
- Git 프로젝트는 추적 파일과 무시되지 않은 미추적 파일을 사용합니다.
- 전체 생성은 120초/64 MiB, 변경 파일 갱신은 10초/16 MiB로 제한합니다.
- 외부 도구로 변경·삭제한 파일은 `:CtagsUpdate`로 반영합니다.

캐시는 `stdpath('data')/offline/tags/`에 저장합니다. 연결된 경로는 `:setlocal tags?`로
확인합니다. 미저장 편집, C++ 오버로드·템플릿, Python 동적 속성을 정확히 분석하지는 않습니다.

## 제한

검색은 `find`, `git`, `rg` 또는 `grep` 등 설치된 명령을 사용합니다.
외부 작업은 기본 5초·출력 2 MiB로 제한하고, `:OfflineCancel`로 취소합니다.
파일/검색 후보 최대 10,000개, 표시 결과 최대 200개, 디스크 미리보기 앞 64 KiB입니다.
파일 탐색은 `.git`, `node_modules`, `__pycache__`, `.venv`, `venv`, `build`,
`build-*`, `cmake-build-*`, `dist` 디렉터리를 제외합니다.
2 MiB 초과 파일은 포맷팅을 제한합니다. LSP·구문 강조·자동완성은 2 MiB, 50,000줄,
한 줄 10,000바이트 중 하나라도 초과하면 중지하며 자동 줄바꿈과 커서 십자 강조도 끕니다.
편집 중에도 검사하고, 해당 버퍼의 LSP 연결과 예약·실행 중인 태그 갱신을 중지합니다.
큰 파일의 ctags 정의·아웃라인 요청도 생략합니다. 보호는 파일을 다시 읽을 때까지 유지합니다.
Git 줄 표시는 256 KiB·20,000줄까지이며, 사인 2,000개를 초과하는 변경은 표시를 생략합니다.
수정/추가 구분의 정밀 비교는 한 번의 갱신에서 4,096쌍·줄당 256바이트로 제한합니다.
세션 파일은 미저장 편집 내용을 백업하지 않습니다.

API 기준: [Neovim 0.12 변경 사항](https://neovim.io/doc/user/news-0.12/),
[내장 LSP 자동완성](https://neovim.io/doc/user/lsp/#lsp-completion).

### 상태줄 Git 정보

상태줄에 `[git:브랜치 XY]`를 표시합니다. 현재 파일이 깨끗하면 XY는 생략합니다.
XY의 첫 글자는 스테이징 상태, 둘째는 디스크의 작업 파일 상태이며 `.`은 변경 없음을 뜻합니다.
예: `.M` 저장된 수정, `M.` 스테이징된 수정, `A.` 스테이징된 새 파일, `??` 미추적 파일.
미저장 편집은 기존 `[+]`로 표시하며, detached HEAD에서는 짧은 커밋 해시를 표시합니다.
파일 진입·저장·포커스 복귀·내장 터미널 복귀 시 비동기로 조회하고, 커서 이동 때는 조회하지 않습니다.

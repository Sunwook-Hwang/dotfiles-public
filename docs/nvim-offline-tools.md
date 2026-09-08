# Offline Neovim: LSP·포맷터 설치 가이드

`init.offline.lua`는 Neovim 0.12 이상에서 동작하며 도구를 설치하지 않습니다.
LSP와 포맷터 실행 파일은 기본적으로 `~/.config/nvim/lsp/bin/`에 놓습니다.
아래는 관리자 권한 없이 Linux 서버의 사용자 홈에 설치하는 예입니다. 필요한 언어만 설치하세요.
macOS에서 준비해 Linux로 옮길 때는 서버용 Linux 배포 파일을 받아야 합니다.

## 1. 현재 설정이 찾는 위치

| 종류 | 검색 순서 |
| --- | --- |
| LSP 서버 | `~/.config/nvim/lsp/bin` → PATH → 기존 `stdpath("data")/mason/bin` |
| 외부 포맷터 | `~/.config/nvim/lsp/bin` → PATH |
| Git·검색 | PATH의 `git`, `find`, `rg` 또는 `grep` |
| Ctags fallback | `g:offline_ctags` 지정값 및 PATH 후보에서 Universal 우선, 없으면 Exuberant |

Mason은 필요 없습니다. 기존 Mason 경로가 있어도 플러그인을 로드하거나 설치하지 않습니다.
PATH에 실행 파일이 있어도 현재 `init.offline.lua`의 `servers` 목록에 등록된 서버만 연결합니다.
Tailwind·ESLint는 프로젝트 설정/의존성, Emmet은 `.emmet.json` 또는 `emmet.json`이 필요합니다.
Ctags 준비와 명령은 [ctags fallback 가이드](nvim-offline.md#ctags-fallback)를 참고하세요.
명령 별칭(alias)은 실행 파일 검색 대상이 아닙니다. 실제 파일, 정상적인 심볼릭 링크 또는 wrapper를 사용하세요.

권장 배치:

```text
~/.config/nvim/init.offline.lua
~/.config/nvim/lsp/bin/               # LSP·formatter launcher, binary, symlink
~/.local/bin/                         # 필요한 wrapper
~/.local/opt/nvim-tools/
├── node-tools/node_modules/.bin/     # npm으로 설치한 LSP·Prettier 진입점
├── python/bin/                       # 서버에서 만든 venv: 대체 포맷터 black
├── lua-language-server/              # LuaLS 배포본 전체
├── stylua/bin/stylua
└── llvm/bin/                         # clangd, clang-format (배포본의 lib 등도 보존)
```

`lsp/bin`에는 실행 파일 본체, 심볼릭 링크 또는 wrapper를 놓을 수 있습니다. 예:

```sh
mkdir -p "$HOME/.config/nvim/lsp/bin"
ln -s "$HOME/.local/opt/nvim-tools/python/bin/black" "$HOME/.config/nvim/lsp/bin/black"
ln -s "$HOME/.local/opt/nvim-tools/llvm/bin/clangd" "$HOME/.config/nvim/lsp/bin/clangd"
ln -s "$HOME/.local/opt/nvim-tools/llvm/bin/clang-format" "$HOME/.config/nvim/lsp/bin/clang-format"
```

전체 배포본이 필요한 LuaLS·Node 도구는 본체 폴더를 그대로 보존하고 `lsp/bin`에 launcher만 놓으세요.
`vim.g.offline_tools_dir`를 init 파일 앞쪽에 설정하면 기본 폴더를 바꿀 수 있습니다.

```lua
vim.g.offline_tools_dir = vim.fn.expand("~/.local/opt/nvim-tools/bin")
```

PATH fallback을 쓰려면 Bash는 `~/.bashrc`, Zsh는 `~/.zshrc`에 다음을 추가합니다.
Node.js를 별도로 압축 해제했다면 그 배포본의 `bin`도 PATH에 추가해야 합니다.

```sh
export PATH="$HOME/.local/bin:$HOME/.local/opt/nvim-tools/node-tools/node_modules/.bin:$HOME/.local/opt/nvim-tools/python/bin:$HOME/.local/opt/nvim-tools/stylua/bin:$HOME/.local/opt/nvim-tools/llvm/bin:$PATH"
```

현재 셸에도 이 줄을 실행한 다음 **그 셸에서 Neovim을 새로 실행**합니다.
이미 실행 중인 Neovim에는 변경된 셸의 PATH가 전달되지 않습니다.

## 2. 언어별 필요한 도구

| 언어 | LSP 실행 파일 | 설치 패키지/배포본 | 현재 외부 포맷터 |
| --- | --- | --- | --- |
| Python | `ty server` → 없으면 `pyright-langserver` | ty 실행 파일 또는 npm `pyright` + Node.js | `ruff format` → 없으면 `black` |
| C/C++ | `clangd` | clangd/LLVM | `clang-format` |
| Lua | `lua-language-server` | LuaLS 배포본 | `stylua` |
| JavaScript | `typescript-language-server` | npm `typescript-language-server` + 호환 `typescript` | `prettier` |
| TypeScript·JSX·TSX | `typescript-language-server` | 위와 같음 | LSP 포맷팅으로 fallback |
| HTML·CSS/SCSS/Less | `vscode-html-language-server`, `vscode-css-language-server` | npm `vscode-langservers-extracted` | LSP 포맷팅으로 fallback |

**현재 Prettier 외부 호출은 `javascript` 파일 타입에만 등록되어 있습니다.**
Prettier를 설치했다고 TypeScript·JSON·HTML에도 자동 적용되는 것은 아닙니다.
필요하면 `init.offline.lua`의 `formatters` 테이블에 파일 타입을 추가해야 합니다.
Python LSP는 ty를 먼저 찾고 없을 때만 Pyright를 사용합니다. 각 후보는 위 설치 위치 순서로 찾습니다.
Python 포맷팅은 Ruff를 먼저 찾고 없으면 Black을 사용하며, 두 도구를 연속 실행하지 않습니다.
Ruff는 포맷터로만 사용하고 LSP로 실행하지 않습니다. isort는 더 이상 필요하지 않습니다.

추가로 등록된 웹 LSP는 다음과 같습니다. 해당 언어를 쓸 때만 설치하세요.

| 실행 파일 | npm 패키지 |
| --- | --- |
| `tailwindcss-language-server` | `@tailwindcss/language-server` |
| `svelteserver` | `svelte-language-server` |
| `graphql-lsp` | `graphql-language-service-cli` |
| `emmet-ls` | `emmet-ls` |
| `prisma-language-server` | `@prisma/language-server` |
| `vscode-eslint-language-server` | `vscode-langservers-extracted` |

실행 파일 설치와 프로젝트 설정은 별개입니다. ESLint·Tailwind·GraphQL 등은 프로젝트의
패키지와 설정 파일도 필요할 수 있습니다. 설치 버전의 Node.js 요구 사항을 확인하세요.

## 3. 인터넷을 사용할 수 있는 환경에서 설치

다음 설치 명령은 인터넷이 되는 서버 또는 준비용 머신에서 실행합니다.
재현이 필요하면 검증한 패키지 버전을 지정하고 생성된 lock 파일을 보관하세요.

### Python LSP와 포맷터

기본 조합은 ty와 Ruff입니다. 준비한 `ty`, `ruff` 실행 파일을 `~/.config/nvim/lsp/bin/` 또는
PATH에 배치합니다. 아래는 이 도구들이 없을 때 사용하는 Pyright·Black의 설치 예입니다.

Pyright의 npm 설치는 Node.js가 필요합니다. [Pyright 설치 문서](https://github.com/microsoft/pyright/blob/main/docs/installation.md)

```sh
mkdir -p "$HOME/.local/opt/nvim-tools/node-tools"
npm install --prefix "$HOME/.local/opt/nvim-tools/node-tools" --save-exact pyright
python3 -m venv "$HOME/.local/opt/nvim-tools/python"
"$HOME/.local/opt/nvim-tools/python/bin/python" -m pip install black
```

프로젝트에서 사용하는 Python 환경은 포맷터용 venv와 별개입니다.
Python 파일에서 `Space lv`로 프로젝트 환경을 선택하세요.
연결은 되는데 import 오류가 나면 선택한 환경에 패키지가 설치되어 있는지 확인합니다.

### JavaScript/TypeScript·HTML/CSS

Node.js와 npm이 필요합니다. TypeScript 서버는 별도의 TypeScript 패키지를 요구합니다.
아래 `typescript@6`은 확인 시점의 서버 안내에 맞춘 예이며, 서버 버전을 고정할 경우 해당 버전의 요구 사항을 따르세요.
[TypeScript 서버 설치 문서](https://github.com/typescript-language-server/typescript-language-server#installing)

```sh
npm install --prefix "$HOME/.local/opt/nvim-tools/node-tools" --save-exact \
  typescript-language-server typescript@6 vscode-langservers-extracted prettier
```

이 가이드는 도구 전용 디렉터리에 설치합니다. 프로젝트에 이미 고정된 Prettier가 있다면
그 프로젝트의 `node_modules/.bin`을 명시적으로 PATH에 넣어 실행할 수도 있습니다.
현재 설정은 프로젝트의 `node_modules/.bin`을 자동 검색하지 않습니다.
[Prettier 설치 문서](https://prettier.io/docs/install.html)

### C/C++: clangd와 clang-format

서버 배포판의 패키지 관리자 또는 [clangd 공식 설치 안내](https://clangd.llvm.org/installation)를 이용합니다.
배포판으로 설치하면 실행 파일이 `/usr/bin` 등 기존 PATH에 놓일 수 있어 별도 복사가 필요 없습니다.
사용자 홈에 LLVM 배포본을 풀었다면 `bin`, `lib` 등 원래 디렉터리 구조를 유지하세요.
clangd만 포함된 배포본에는 clang-format이 없을 수 있으므로 둘 다 확인합니다.

```sh
command -v clangd
command -v clang-format
clangd --version
clang-format --version
```

헤더·매크로·컴파일 옵션을 정확하게 분석하려면 프로젝트의 `compile_commands.json`이 필요합니다.
CMake 프로젝트에서는 다음처럼 생성할 수 있습니다. 서버에서 빌드한 경로를 사용하세요.
[clangd 프로젝트 설정](https://clangd.llvm.org/installation#project-setup)

```sh
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

### Lua: LuaLS와 StyLua

[LuaLS 배포본](https://github.com/LuaLS/lua-language-server/releases)을 받아
`~/.local/opt/nvim-tools/lua-language-server/` 아래에 **전체를** 풉니다.
최상위에 `main.lua`, `bin/` 등이 있는지 확인하세요. 실행 파일만 옮기면 리소스를 찾지 못할 수 있습니다.
wrapper는 실제 배포 디렉터리에서 실행하도록 만듭니다. [LuaLS 설치 안내](https://luals.github.io/#install)

```sh
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/lua-language-server" <<'SH'
#!/bin/sh
cd "$HOME/.local/opt/nvim-tools/lua-language-server" || exit 1
exec ./bin/lua-language-server "$@"
SH
chmod +x "$HOME/.local/bin/lua-language-server"
```

[StyLua 릴리스](https://github.com/JohnnyMorganz/StyLua/releases)에서 서버 OS·CPU에 맞는 파일을 받아
압축을 푼 `stylua` 실행 파일을 `~/.local/opt/nvim-tools/stylua/bin/stylua`에 놓습니다.
[StyLua 설치 안내](https://github.com/JohnnyMorganz/StyLua#installation)

```sh
chmod +x "$HOME/.local/opt/nvim-tools/stylua/bin/stylua"
stylua --version
```

## 4. 인터넷 없는 서버로 옮기기

### 준비 환경 확인

서버에서 먼저 OS·CPU·런타임 버전을 확인합니다.

```sh
uname -s
uname -m
python3 --version
node --version
```

준비용 환경은 서버와 OS·CPU·libc 및 필요한 런타임 버전을 맞추세요.
macOS 실행 파일이나 macOS에서 만든 venv를 Linux 서버에 복사하는 방식은 사용하지 않습니다.
Node.js, Python/venv 지원, 공유 라이브러리가 서버에 없다면 이 런타임도 먼저 준비해야 합니다.
Linux 바이너리 실행에서 `GLIBC_x.y not found`가 나오면 서버와 호환되는 배포본/빌드가 필요합니다.

### Node 도구: 설치 폴더 전체 전달

서버와 호환되는 인터넷 연결 환경에서 3장의 npm 설치를 실행한 후 압축합니다.
`node_modules/.bin`은 다른 파일을 가리키는 링크이므로 그 폴더만 복사하면 안 됩니다.

```sh
tar -czf nvim-node-tools.tar.gz -C "$HOME/.local/opt/nvim-tools" node-tools
```

이 파일을 서버로 전송한 다음 서버에서 실행합니다.

```sh
mkdir -p "$HOME/.local/opt/nvim-tools"
tar -xzf nvim-node-tools.tar.gz -C "$HOME/.local/opt/nvim-tools"
```

`node-tools` 전체에 의존성·package.json·package-lock.json을 포함합니다.
서버에서는 npm install을 다시 실행하지 않습니다. 서버 PATH의 `node`로 실행합니다.
Node.js 자체가 없다면 서버용 Node 배포본도 별도로 전달하고 그 `bin`을 PATH에 추가합니다.

### 대체 포맷터 Black: wheel 전달 후 서버에서 venv 생성

서버와 같은 Python 버전·플랫폼의 인터넷 연결 환경에서 다운로드합니다.
`--only-binary=:all:`로 소스 빌드 의존성이 서버에서 추가 다운로드되는 것을 피합니다.
해당 플랫폼의 wheel이 없으면 여기서 실패하므로 호환 버전을 선택하거나 준비 환경에서 wheel을 빌드해야 합니다.
[pip download 문서](https://pip.pypa.io/en/stable/cli/pip_download/)

```sh
python3 -m pip download --only-binary=:all: --dest wheelhouse black
tar -czf nvim-python-wheels.tar.gz wheelhouse
```

압축 파일을 서버에 전송하고, 서버에서 설치합니다.

```sh
tar -xzf nvim-python-wheels.tar.gz
python3 -m venv "$HOME/.local/opt/nvim-tools/python"
"$HOME/.local/opt/nvim-tools/python/bin/python" -m pip install \
  --no-index --find-links=wheelhouse black
```

venv는 실행 스크립트에 절대 경로가 들어가므로 다른 머신에서 만든 venv를 옮기지 않고
**서버의 최종 경로에서 생성**합니다. wheelhouse에는 다운로드된 의존성도 모두 포함해야 합니다.

### 네이티브 도구 전달

clangd/LLVM·LuaLS는 서버용 배포 디렉터리를 통째로, StyLua는 서버용 실행 파일을 전달합니다.
심볼릭 링크와 실행 권한을 보존할 수 있도록 `tar`로 묶어서 옮기는 편이 간단합니다.
Mason 폴더 전체를 복사하는 것은 필수가 아니며, 다른 OS에서 설치한 Mason 도구도 그대로 실행되지 않습니다.

## Neovim에서 Python 환경 선택

Python 파일에서 **`Space l v`**를 누르면 기존 검색형 선택 창이 열립니다.
프로젝트의 `.venv`·`venv`, 실행 당시 활성 venv/Conda, PATH의 Python 중 실행 가능한 후보를 표시합니다.
Conda가 있으면 `conda env list --json`으로 비활성 환경도 비동기로 추가합니다.
PATH의 `conda` 또는 `CONDA_EXE`를 사용하며, 중복 경로와 Python 실행 파일이 없는 환경은 제외합니다.
조회 실패 시 기존 후보와 직접 경로 입력을 사용할 수 있습니다.
후보를 검색하고 `Ctrl-n/p`로 이동한 뒤 Enter로 선택합니다. Esc는 취소입니다.

- `Enter Python path...`: Python 실행 파일 또는 가상환경 폴더를 직접 입력합니다.
  `~/envs/myproject`와 프로젝트 기준 상대 경로도 사용할 수 있습니다.
- `Automatic`: 수동 지정을 해제하고 프로젝트 설정/기존 PATH로 돌아갑니다.
- 선택은 Neovim 실행 중 프로젝트별로 기억하며 `Space ls`로 LSP를 재시작해도 유지됩니다.
  Neovim을 종료하면 초기화됩니다. 프로젝트 기준은 기존 설정과 동일하게 Git 루트를 우선합니다.

ty에는 `ty.configuration.environment.python`을 전달하고, 변경한 프로젝트의 ty만 재시작해
패키지 검색 경로를 갱신합니다. 같은 환경을 재선택하면 재시작하지 않습니다.
패키지 이름이나 함수에서 `gd`를 누르면 선택한 환경의 정의로 이동합니다.
Pyright를 사용할 때는 `python.pythonPath`와 설정 변경 알림으로 반영합니다.
가상환경이나 패키지를 설치하지 않으며 터미널·포맷터의 PATH는 변경하지 않습니다.
LSP 미연결 상태에서 선택하면 이후 해당 프로젝트에 연결될 때 적용합니다.
`pyrightconfig.json`의 `venv`/`venvPath`로 환경을 지정했다면 그 설정이 우선할 수 있으니
선택한 환경과 충돌하는 설정을 확인하세요.
[Pyright 설정](https://github.com/microsoft/pyright/blob/main/docs/settings.md),
[환경 선택 우선순위](https://github.com/microsoft/pyright/blob/main/docs/import-resolution.md#configuring-your-python-environment).

## 5. 설치 확인 및 문제 해결

Python 작업 기준으로 셸에서 확인합니다. 다른 언어라면 표의 실행 파일 이름으로 바꾸세요.

```sh
command -v ty
command -v ruff
ty --version
ruff --version
nvim -u ~/.config/nvim/init.offline.lua example.py
```

`lsp/bin`에만 배치했다면 해당 파일의 전체 경로로 버전을 확인하세요.
대체 도구를 사용한다면 `node`, `pyright-langserver`, `black`의 설치를 확인합니다.

LSP 프로세스를 직접 `--stdio`로 실행하면 입력을 기다리며 멈춘 것처럼 보일 수 있습니다.
실제 연결 여부는 파일을 열고 Neovim 안에서 확인하세요.

```vim
:lua print(vim.fn.exepath('ty'))
:lua print(vim.fn.exepath('ruff'))
:lua print(vim.fn.stdpath('config') .. '/lsp/bin')
:checkhealth vim.lsp
:lua vim.print(vim.lsp.get_clients({bufnr=0}))
:lua print(vim.fn.stdpath('data') .. '/mason/bin')
```

`exepath()`는 PATH 확인용입니다. 빈 문자열이어도 LSP는 `lsp/bin` 또는 기존 Mason 경로에서 찾았을 수 있습니다.
현재 등록 명령은 `:lua vim.print(vim.lsp.config.ty or vim.lsp.config['pyright-langserver'])`로 확인합니다.
서버를 설치한 뒤에는 Neovim을 재실행하세요. 시작할 때 실행 파일이 없던 서버는 활성화되지 않습니다.

- `K`, `gd`, Insert `Ctrl-Space`: LSP 도움말·정의·완성 확인
- `Space Tr`: LSP가 제공하는 함수·클래스 아웃라인 확인
- `Space l f`: 포맷팅. 버퍼가 바뀌며 디스크 저장은 별도로 수행합니다.
- `:messages`: 서버 시작·포맷터 오류 확인
- `:set filetype?`: 해당 언어 파일로 인식했는지 확인

포맷터가 없으면 LSP 포맷팅을 시도하지만 서버가 지원하지 않으면 포맷팅되지 않습니다.
저장 시 자동 포맷팅은 꺼져 있습니다. 2 MiB 초과 파일은 LSP·포맷팅을 제한합니다.
언어 서버의 연결 성공과 프로젝트 환경 분석 성공은 별개이므로 Python 환경, C/C++ 컴파일 DB,
웹 프로젝트 설정도 함께 확인하세요.

[offline 기능·단축키 가이드로 돌아가기](nvim-offline.md)

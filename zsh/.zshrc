export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export TERM=xterm-256color

export ZSH=$HOME/.oh-my-zsh
export PATH=/opt/homebrew/bin:$PATH
export PATH=/opt/homebrew/sbin:$PATH
export PATH=$HOME/.local/bin:$PATH

alias tmux='env TERM=xterm-256color tmux'
alias tad='tmux at -d'

alias lg='lazygit'
unalias vi pvi npvi onvi offvi 2>/dev/null || true
unfunction pvi npvi 2>/dev/null || true

# Persist the selected Neovim profile; vi without a selector reuses it.
function vi {
  local mode_file="${XDG_STATE_HOME:-$HOME/.local/state}/nvim-mode"
  local app=nvim-nopack
  case "${1:-}" in
  --pack | --nopack)
    [[ "$1" == --pack ]] && app=nvim
    shift
    mkdir -p "${mode_file:h}" && printf '%s\n' "$app" >"$mode_file" || return
    ;;
  *) [[ -r "$mode_file" ]] && IFS= read -r app <"$mode_file" ;;
  esac
  case "$app" in nvim | nvim-nopack) ;; *) app=nvim-nopack ;; esac
  NVIM_APPNAME="$app" command nvim "$@"
}
alias pvi='vi --pack'
alias npvi='vi --nopack'

alias neovide='neovide -- -u $HOME/.config/nvim/neovide-terminal.lua'

ZSH_THEME="robbyrussell"
ZSH_DISABLE_COMPFIX="true"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  autojump
)

source $ZSH/oh-my-zsh.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniforge/base/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh" ]; then
    . "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh"
  else
    export PATH="/opt/homebrew/Caskroom/miniforge/base/bin:$PATH"
  fi
fi
unset __conda_setup
# <<< conda initialize <<<

export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export TERM=xterm-256color

export ZSH=$HOME/.oh-my-zsh
export PATH=/opt/homebrew/bin:$PATH
export PATH=/opt/homebrew/sbin:$PATH

alias tmux='env TERM=xterm-256color tmux'
alias tad='tmux at -d'

alias vi='nvim'
alias lg='lazygit'

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

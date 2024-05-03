# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export TERM=xterm-256color
# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export PATH=$HOME/.local/bin:$PATH
export PATH=/usr/local/sbin:$PATH
# export PYTHONPATH="${PYTHONPATH}:/root/second.pytorch"
export PYTHONPATH="${PYTHONPATH}:/root/OpenPCDet/pcdet"
export PATH=/opt/homebrew/bin:$PATH
export PATH=$PATH:$HOME/node_modules/.bin
export PATH=$HOME/.cargo/bin:$PATH
export PATH=/opt/homebrew/sbin:$PATH

alias lua='lua5.3'
alias tmux='env TERM=xterm-256color tmux'
alias tad='tmux at -d'
# alias tmux='tmux -2'

alias run_docker='sh $HOME/dotfiles/Dockerfiles/run_docker.sh'
alias run_upcycling='sh $HOME/dotfiles/Dockerfiles/run_UpCycling.sh'
alias run_ucpp='sh $HOME/dotfiles/Dockerfiles/run_neuralcompression.sh'
alias upcycling_code_edit='sh $HOME/dotfiles/Dockerfiles/upcycling_code_edit.sh'
alias run_spconv2='sh $HOME/dotfiles/Dockerfiles/run_spconv2.sh'
alias run_spconv2_2='sh $HOME/dotfiles/Dockerfiles/run_spconv2_2.sh'
alias run_spconv2_3='sh $HOME/dotfiles/Dockerfiles/run_spconv2_3.sh'
alias run_spconv2_aiot='sh $HOME/dotfiles/Dockerfiles/run_spconv2_aiot.sh'
alias run_spconv2_aiot_2='sh $HOME/dotfiles/Dockerfiles/run_spconv2_aiot_2.sh'
alias run_spconv2_aiot_3='sh $HOME/dotfiles/Dockerfiles/run_spconv2_aiot_3.sh'
alias run_conda_upcycling='sh $HOME/dotfiles/Dockerfiles/run_conda_upcycling.sh'
alias run_tensorboard='sh $HOME/dotfiles/Dockerfiles/run_tensorboardx.sh'

alias dvim='docker run -it --rm \
    -v $(pwd):/root/src/ \
    -e TZ=Asia/Seoul \
    sunwookh/working_space:vim nvim'

alias dvim_zsh='docker run -it --rm \
    -v $(pwd):/root/src/ \
    -e TZ=Asia/Seoul \
    sunwookh/working_space:vim zsh'

alias vi='lvim'
alias lg='lazygit'
# alias vi='nvim -i NONE'
# alias vis="nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"
# alias vif='nvim $(fzf)'

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
ZSH_DISABLE_COMPFIX="true"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    autojump
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#
# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/root/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/root/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/root/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/root/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<
#

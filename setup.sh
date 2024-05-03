#!/bin/bash

SOURCE=$PWD/source
CURDIR=$PWD
USERDIR=$PWD/..

# CHECK PACKAGE
function pkg_install {
    for name in $1
    do
        if [[ $name != "\\" ]]
        then
            if [[ $(dpkg -s ${name} | grep Status) == *"installed" ]]
            then
                echo "[-] $1 is already installed"
            else
                sudo apt-get install -y $1
            fi
        fi
    done
}

function zsh_setup {
    echo "[*] zsh_setup"

    source $CURDIR/clean_dotfiles.sh

    # prerequisite for zsh setup
    pkg_install "fzf"

    pkg_install "zsh"
    source $SOURCE/ohmyzsh.sh --skip-chsh
    pkg_install "autojump"
    # git clone https://github.com/wting/autojump ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autojump
    # pushd ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autojump
    # ./install.py
    # popd
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    rm -f $USERDIR/.zshrc

    chsh -s $(which zsh)
}

function tmux_setup {
    echo "[*] tmux_setup"

    source $CURDIR/clean_dotfiles.sh
    pkg_install "tmux"
    #     pushd $SOURCE/tmux_setup
    #     ./install.sh
    #     popd
    rm -f $USERDIR/.tmux.conf
}

function nvim_setup {
    echo "[*] nvim_setup"

    source $CURDIR/clean_dotfiles.sh
    # source $SOURCE/neovim.sh

    # prerequisite for neovim setup
    pkg_install "ninja-build"
    pkg_install "gettext"
    pkg_install "libtool"
    pkg_install "libtool-bin"
    pkg_install "autoconf"
    pkg_install "automake"
    pkg_install "cmake"
    pkg_install "g++"
    pkg_install "pkg-config"
    pkg_install "unzip"
    pkg_install "curl"

    git clone https://github.com/neovim/neovim.git $USERDIR/neovim
    pushd $USERDIR/neovim
    sudo make install
    popd

    sudo rm -rf $USERDIR/neovim
    rm -f $USERDIR/.config/nvim/init.vim $USERDIR/.config/nvim/init.lua
}

function npm_setup {
    echo "[*] npm_setup"

    pkg_install "npm"
    npm cache clean -f && npm install -g n && sudo n stable && PATH="$PATH"
}

function locales_setup {
    pkg_install "locales"
    locale-gen en_US.UTF-8

}

function base_setup {
    echo "[*] base_setup"

    sudo apt-get update
    pkg_install "build-essential"
    pkg_install "wget"
    pkg_install "git"
    pkg_install "ripgrep"
    pkg_install "vim"
    pkg_install "htop"
    pkg_install "curl"
    pkg_install "python3"
    pkg_install "pip"
    pkg_install "nodejs"
    pkg_install "stow"
    pkg_install "tree"
    pkg_install "tldr"
    pkg_install "rustc"
    pkg_install "software-properties-common"

    npm_setup
    locale_setup

    sudo apt-get clean
}

function core_setup {
    zsh_setup
    tmux_setup
    nvim_setup
}

# ==================================================================
############ MAIN ############
# ------------------------------------------------------------------

if [[ ${1} == "" ]]
then
    PATH=$PATH
    base_setup
    core_setup
    # pushd $CURDIR
    ./install_dotfiles.sh
    # popd
    zsh
elif [[ ${1} == "base" ]]
then
    echo "*** BASE SETUP ***"
    ${1}_setup
elif [[ ${1} == "link" ]]
then
    echo "*** LINK DOTFILES ***"
    # pushd $CURDIR
    ./install_dotfiles.sh
    # popd
elif [[ ${1} == "unlink" ]]
then
    echo "*** UNLINK DOTFILES ***"
    # pushd $CURDIR
    ./clean_dotfiles.sh.sh
    # popd
else
    ${1}_setup
fi

sudo apt-get clean

#!/usr/bin/env bash
# Setup script for setting up a new macos machine

SOURCE=$PWD/source
CURDIR=$PWD
USERDIR=$PWD/..

echo "Starting setup"
# install xcode CLI
xcode-select --install

set +e
set -x

function brew_setup {
    # Check for Homebrew to be present, install if it's missing
    if test ! "$(command -v brew)"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        export PATH=/opt/homebrew/bin:$PATH
    else
        if [[ -z "${CI}" ]]; then
            brew update
            brew upgrade --greedy
            brew doctor
        fi
    fi
}

function font_setup {
    brew update
    brew tap homebrew/cask-fonts
    echo "Installing fonts..."
    FONTS=(
        font-roboto-mono-nerd-font
    )
    echo "Installing cask fonts..."
    brew install ${FONTS[@]} --force
}

function cask_setup {
    brew update
    echo "Installing cask..."
    brew tap homebrew/homebrew-core
    CASKS=(
        google-chrome
        google-drive
        iterm2
        microsoft-excel
        microsoft-powerpoint
        microsoft-remote-desktop
        microsoft-word
        qmk-toolbox
        ridibooks
        skim
        slack
        spotify
        visual-studio-code
        zoom
    )
    echo "Installing cask apps..."
    brew install --cask ${CASKS[@]} --force
}

function base_setup {
    brew update
    PACKAGES=(
        bat
        curl
        fd
        fzf
        git
        htop
        neovim
        node
        prettier
        python3
        ripgrep
        rust
        stow
        stylua
        tldr
        tmux
        tree
        vim
        wget
    )
    echo "Installing packages..."
    brew install ${PACKAGES[@]}
}

function zsh_setup {
    echo "[*] zsh_setup"

    source $CURDIR/clean_dotfiles.sh

    # prerequisite for zsh setup
    source $SOURCE/ohmyzsh.sh --skip-chsh
    PACKAGES=(
        autojump
        zsh-autosuggestions
        zsh-syntax-highlighting
    )

    echo "Installing packages..."
    brew install ${PACKAGES[@]}

    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

    rm -f $USERDIR/.zshrc
}

# ==================================================================
############ MAIN ############
# ------------------------------------------------------------------

if [[ ${1} == "" ]]
then
    brew_setup

    base_setup
    zsh_setup

    cask_setup
    font_setup

    source $CURDIR/install_dotfiles.sh

elif [[ ${1} == "base" ]]
then
    echo "*** BASE SETUP ***"
    ${1}_setup
elif [[ ${1} == "link" ]]
then
    echo "*** LINK DOTFILES ***"
    source $CURDIR/install_dotfiles.sh
elif [[ ${1} == "unlink" ]]
then
    echo "*** UNLINK DOTFILES ***"
    source $CURDIR/clean_dotfiles.sh
else
    ${1}_setup
fi
brew cleanup --prune=0

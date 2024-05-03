# MacOS and linux settings

## Linux setup
### CORE: tmux, zsh, neovim

```sh
apt-get upate && apt-get install -y sudo git
git clone --depth 1 https://github.com/Sunwook-Hwang/dotfiles ~/dotfiles
cd ~/dotfiles
sudo ./setup.sh
```

### TMUX setting

Switch command keys
- `Command mode`: Ctrl-a
- `Moving commands`: h,j,k,l

### ZSH setting

Plugins: autojump, zsh-syntax-highlighting, zsh-autosuggestions

### NEOVIM setting

### Rg Installation
```sh
sudo add-apt-repository ppa:x4121/ripgrep
sudo apt-get update
sudo apt-get install ripgrep
```

### STOW dotfiles: Included in setup.sh
```sh
./install_dofiles.sh
./clean_dotfiles.sh
```

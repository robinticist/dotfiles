# Dotfiles Setup

This document provides a guide for setting up dotfiles. Before starting the setup, make sure [Homebrew](https://brew.sh/) is installed.

## Requirements

1. **Install Homebrew**
   If Homebrew is not installed, run the following command in your terminal to install it:

   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"  
    ```
2. **Install Packages**  

    brew install git  
    brew install alacritty  
    brew install font-meslo-lg-nerd-font  
    brew install stow  
    

## Install Packages
brew install powerlevel10k  
brew install bat  
brew install neovim   
brew install tmux  
brew install fzf  
brew install oh-my-posh  
brew install zsh-autosuggestions  
brew install zsh-syntax-highlighting  
brew install eza  
brew install zoxide  

git clone https://github.com/alacritty/alacritty-theme ~/dotfiles/.config/alacritty/themes  
git clone https://github.com/tmux-plugins/tpm ~/dotfiles/.tmux/plugins/tpm  

## Link and Install command
* ~/dotfiles >> stow . (symlink)
* nvim . (install nvim settings)
* tmux >> ctrl + o >> I (install tmux theme)
  * tmux source-file ~/.tmux.conf (set immediately)
* powerlevel10k setup command
    
    ```bash 
    p10k configure
    ```
    

## How to use

* tmux (prefix: ctrl + o)  

    | keymap | actions |
    | ------ | ------ |
    | prefix + c | Create New Pane |
    | prefix + h | Split Pane Horizontally |
    | prefix + v | Split screen Vertically |

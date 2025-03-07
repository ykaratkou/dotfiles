#!/bin/bash

echo "Configuring Fish"
ln -s $HOME/.dotfiles/fish/ $HOME/.config/

echo "Configuring NVIM"
ln -s $HOME/.dotfiles/nvim $HOME/.config/

echo "Configuring tmux"
ln -s $HOME/.dotfiles/.tmux.conf $HOME/.tmux.conf

echo "Configuring Git"
echo "{{ op://Personal/vxzclei6krdlhms7kbjftcdmw4/public key }}" | op inject > $HOME/.ssh/personal.pub
ln -s $HOME/.dotfiles/git/.gitconfig $HOME/.gitconfig
ln -s $HOME/.dotfiles/git/.gitignore $HOME/.gitignore

echo "Configuring other files"
ln -s $HOME/.dotfiles/.irbrc $HOME/.irbrc
ln -s $HOME/.dotfiles/.ripgreprc $HOME/.ripgreprc
ln -s $HOME/.dotfiles/.gemrc $HOME/.gemrc

echo "Configuring Alacritty"
mkdir -p $HOME/.config/alacritty
mkdir -p $HOME/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme $HOME/.config/alacritty/themes
ln -s $HOME/.dotfiles/alacritty.toml $HOME/.config/alacritty/

echo "Configuring Bat"
mkdir -p $HOME/.config/bat
ln -s $HOME/.dotfiles/bat/config $HOME/.config/bat/

echo "Configuring lazygit"
mkdir -p $HOME/.config/lazygit
ln -s $HOME/.dotfiles/lazygit/config.yml $HOME/.config/lazygit/

echo "Configure Bin"
mkdir -p $HOME/.bin
ln -s $HOME/.dotfiles/bin/tmux-sessionizer $HOME/.bin/
ln -s $HOME/.dotfiles/bin/op-aws-helper $HOME/.bin/

echo "Installing mise"
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc

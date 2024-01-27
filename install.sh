#!/bin/bash

echo "Configuring Fish"
ln -s $HOME/.dotfiles/fish/ $HOME/.config/
sudo sh -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
chsh -s /opt/homebrew/bin/fish
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

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
ln -s $HOME/.dotfiles/alacritty.toml $HOME/.config/alacritty

echo "Configuring Bat"
mkdir -p $HOME/.config/bat
ln -s $HOME/.dotfiles/bat/config $HOME/.config/bat

echo "Configure Bin"
mkdir -p $HOME/.bin
ln -s $HOME/.dotfiles/bin/tmux-windowizer $HOME/.bin
ln -s $HOME/.dotfiles/bin/op-aws-helper $HOME/.bin

echo "Installing rtx"
curl https://rtx.pub/install.sh | sh

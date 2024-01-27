# 1. Install Oh My Fish
# curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

if status is-interactive
    # Commands to run in interactive sessions can go here
end

source $HOME/.dotfiles/fish/overrides.d/*.fish

set PATH $HOME/.bin $PATH

if test -d $HOME/.fzf/bin/
  set PATH $HOME/.fzf/bin/ $PATH
end

set fish_greeting
set fish_color_valid_path

set -x RIPGREP_CONFIG_PATH $HOME/.dotfiles/.ripgreprc
set -Ux LSCOLORS gxfxbEaEBxxEhEhBaDaCaD


# 1. Install Oh My Fish
# curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

if status is-interactive
    # Commands to run in interactive sessions can go here
end

source $HOME/.dotfiles/fish/overrides.d/*.fish

set PATH $HOME/.bin $PATH
set XDG_CONFIG_HOME $HOME/.config

if test -d $HOME/.fzf/bin/
  set PATH $HOME/.fzf/bin/ $PATH
end

set fish_greeting
set fish_color_valid_path

set -x RIPGREP_CONFIG_PATH $HOME/.dotfiles/.ripgreprc

# pnpm
set -gx PNPM_HOME "$HOME/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

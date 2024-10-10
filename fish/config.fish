# 1. Install Oh My Fish
# curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

if status is-interactive
    # Commands to run in interactive sessions can go here
end

source $HOME/.config/fish/overrides.d/*.fish

set PATH $HOME/.bin $PATH
set XDG_CONFIG_HOME $HOME/.config

if test -d $HOME/.fzf/bin/
  set PATH $HOME/.fzf/bin/ $PATH
end

set fish_greeting
set fish_color_valid_path

set -gx RIPGREP_CONFIG_PATH $HOME/.ripgreprc
set -gx SHELL $(which fish)

# pnpm
set -gx PNPM_HOME "$HOME/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

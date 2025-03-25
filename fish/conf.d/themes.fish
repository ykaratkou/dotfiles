# initiate the theme if macos_theme was not set
if not set -q macos_theme
  if defaults read -g AppleInterfaceStyle &>/dev/null
    set -Ux macos_theme dark
  else
    set -Ux macos_theme light
  end
end

function update_theme --on-variable macos_theme
  if [ "$macos_theme" = "dark" ]
    sed -i '' 's/light\.toml/dark\.toml/' ~/.dotfiles/alacritty.toml
  else if [ "$macos_theme" = "light" ]
    sed -i '' 's/dark\.toml/light\.toml/' ~/.dotfiles/alacritty.toml
  end
end

# Force apply fzf theme in the new tmux pane
if test -n "$TMUX_PANE"
  update_theme
end

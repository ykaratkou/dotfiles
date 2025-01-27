# initiate the theme if macos_theme was not set
if not set -q macos_theme
  if defaults read -g AppleInterfaceStyle &>/dev/null
    set --universal macos_theme dark
  else
    set --universal macos_theme light
  end
end

function update_theme --on-variable macos_theme
    if [ "$macos_theme" = "dark" ]
      set -Ux FZF_DEFAULT_OPTS "
        --color=fg:#e0def4,bg:#232136,hl:#ea9a97
        --color=fg+:#e0def4,bg+:#393552,hl+:#ea9a97
        --color=border:#44415a,header:#3e8fb0,gutter:#232136
        --color=spinner:#f6c177,info:#9ccfd8
        --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"
    else if [ "$macos_theme" = "light" ]
      set -Ux FZF_DEFAULT_OPTS "
        --color=fg:#797593,bg:#faf4ed,hl:#d7827e
        --color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e
        --color=border:#dfdad9,header:#286983,gutter:#faf4ed
        --color=spinner:#ea9d34,info:#56949f
        --color=pointer:#907aa9,marker:#b4637a,prompt:#797593"
    end
end

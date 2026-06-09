# initiate the theme if macos_theme was not set
if not set -q macos_theme
  if defaults read -g AppleInterfaceStyle &>/dev/null
    set -Ux macos_theme dark
  else
    set -Ux macos_theme light
  end
end

function __apply_fish_theme --description 'Apply fish color theme based on $macos_theme'
  status is-interactive; or return
  switch $macos_theme
    case dark
      fish_config theme choose base16-eighties

      set -Ux FZF_DEFAULT_OPTS "
        --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
        --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
        --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
        --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
    case light
      fish_config theme choose solarized

      set -Ux FZF_DEFAULT_OPTS "
        --color=fg:#657b83,bg:#fdf6e3,hl:#268bd2
        --color=fg+:#586e75,bg+:#eee8d5,hl+:#268bd2
        --color=border:#93a1a1,header:#268bd2,gutter:#fdf6e3
        --color=spinner:#b58900,info:#2aa198
        --color=pointer:#6c71c4,marker:#dc322f,prompt:#657b83"
  end
end

function __on_macos_theme_change --on-variable macos_theme
  __apply_fish_theme
end

__apply_fish_theme

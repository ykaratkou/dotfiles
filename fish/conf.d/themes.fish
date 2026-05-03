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
      fish_config theme choose ayu

      set -Ux FZF_DEFAULT_OPTS "
        --color=fg:#797593,bg:#faf4ed,hl:#d7827e
        --color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e
        --color=border:#dfdad9,header:#286983,gutter:#faf4ed
        --color=spinner:#ea9d34,info:#56949f
        --color=pointer:#907aa9,marker:#b4637a,prompt:#797593"
  end
end

function __on_macos_theme_change --on-variable macos_theme
  __apply_fish_theme
end

__apply_fish_theme

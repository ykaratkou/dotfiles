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
    case light
      fish_config theme choose ayu
  end
end

function __on_macos_theme_change --on-variable macos_theme
  __apply_fish_theme
end

__apply_fish_theme

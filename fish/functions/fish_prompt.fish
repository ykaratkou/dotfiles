set fish_color_autosuggestion 4c566a
set fish_color_cancel \x2d\x2dreverse
set fish_color_command normal
set fish_color_comment 434c5e
set fish_color_cwd green
set fish_color_cwd_root red
set fish_color_end 88c0d0
set fish_color_error ebcb8b
set fish_color_escape 00a6b2
set fish_color_history_current \x2d\x2dbold
set fish_color_host normal
set fish_color_host_remote yellow
set fish_color_match \x2d\x2dbackground\x3dbrblue
set fish_color_normal normal
set fish_color_operator 00a6b2
set fish_color_param eceff4
set fish_color_quote a3be8c
set fish_color_redirection b48ead

function fish_prompt
  set -l cyan (set_color -o cyan)
  set -l yellow (set_color -o yellow)
  set -l red (set_color -o red)
  set -l brred (set_color -o brred)
  set -l green (set_color -o green)
  set -l blue (set_color -o blue)
  set -l white (set_color -o white)
  set -l normal (set_color normal)

  set_color -o
  if test -n "$SSH_TTY"
    echo -n $brred"$USER"$white'@'$yellow(prompt_hostname)' '
  end

  echo -n $blue(prompt_pwd)' '

  if fish_is_root_user
    echo -n $red'# '
  end

  echo -n "$red❯$yellow❯$green❯ "
  set_color normal
end

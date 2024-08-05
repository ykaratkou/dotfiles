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

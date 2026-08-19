function fish_prompt
  # Existing shells do not inherit environment updates when tmux reattaches.
  if set -q TMUX
    for name in SSH_CONNECTION SSH_TTY
      set -l tmux_value (tmux show-environment "$name" 2>/dev/null)
      if string match -q "$name=*" -- "$tmux_value"
        set -gx $name (string replace "$name=" '' -- "$tmux_value")
      else
        set -e $name
      end
    end
  end

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
    echo -n $brred"[$USER]"' '
  end

  echo -n $blue(prompt_pwd)' '

  if fish_is_root_user
    echo -n $red'# '
  end

  echo -n "$red❯$yellow❯$green❯ "
  set_color normal
end

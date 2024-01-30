function fish_right_prompt
  set -l last_command_status $status

  set -l cyan (set_color -o cyan)
  set -l yellow (set_color -o yellow)
  set -l red (set_color -o red)
  set -l brred (set_color -o brred)
  set -l green (set_color -o green)
  set -l blue (set_color -o blue)
  set -l white (set_color -o white)
  set -l normal (set_color normal)

  set -l S (math $CMD_DURATION/1000)
  set -l M (math $S/60)
  set -l duration

  if ! test $last_command_status -eq 0
    set_color red
    echo -n -s (set_color --dim red) $last_command_status (set_color --dim white) ' | '
  end

  if test $M -gt 1
    set duration "$M m"
  else if test $S -gt 1
    set duration "$S s"
  else
    set duration "$CMD_DURATION ms"
  end
  echo -n -s (set_color --dim white) $duration (set_color normal)
end

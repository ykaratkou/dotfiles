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

  if not set -q -g __fish_arrow_functions_defined
    set -g __fish_arrow_functions_defined
    function _git_branch_name
      set -l branch (git symbolic-ref --quiet HEAD 2>/dev/null)
      if set -q branch[1]
        echo (string replace -r '^refs/heads/' '' $branch)
      else
        echo (git rev-parse --short HEAD 2>/dev/null)
      end
    end

    function _is_git_repo
      type -q git
      or return 1
      git rev-parse --git-dir >/dev/null 2>&1
    end

    function _hg_branch_name
      echo (hg branch 2>/dev/null)
    end

    function _is_hg_repo
      fish_print_hg_root >/dev/null
    end

    function _repo_branch_name
      _$argv[1]_branch_name
    end

    function _repo_type
      if _is_hg_repo
        echo hg
        return 0
      else if _is_git_repo
        echo git
        return 0
      end
      return 1
    end
  end

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
  echo -n -s (set_color --dim white) $duration

  set -l repo_info
  if set -l repo_type (_repo_type)
    set -l repo_branch (set_color --dim white)" | "(set_color normal)$green(_repo_branch_name $repo_type)
    set repo_info "$repo_branch"
  end

  echo -n -s $repo_info (set_color normal)
end

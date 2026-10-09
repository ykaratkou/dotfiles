alias RED='RAILS_ENV=development'
alias REP='RAILS_ENV=production'
alias RET='RAILS_ENV=test'

alias rc='rails console'
alias rcs='rails console --sandbox'
alias rs='rails server'
alias rdm='rails db:migrate'
alias rdr='rails db:rollback'
alias rdms='rails db:migrate:status'
alias rr='rails routes'

alias rdr2='rails db:rollback STEP=2'
alias rdr3='rails db:rollback STEP=3'
alias rdr4='rails db:rollback STEP=4'

alias bu='bundle update'
alias bi='bundle install'

alias rd='reviewdog -diff="git diff master"'

# shortcut for running using ruby package manager
alias rspec='bundle exec rspec'

# Run rspec on uncommitted spec files
function rspec_uncommitted
  set -l files (git status --porcelain | grep 'spec/.*_spec\.rb' | awk '{print $2}')
  if test -n "$files"
    bundle exec rspec $files
  else
    echo "No uncommitted spec files found"
  end
end
alias unspec='rspec_uncommitted'

function overmind
  set -l command $argv[1]
  set -l original_overmind (which overmind)

  switch $command
    case s start
      SHELL=/bin/bash $original_overmind $argv
    case '*'
      $original_overmind $argv
  end
end

alias ovr='overmind restart'
alias ovc='overmind connect'
alias ovs='overmind start'

function migrate_up
  set migration (rake db:migrate:status 2>/dev/null | grep '\sdown\s' --color=never | fzf --tac) || return

  rake db:migrate:up VERSION=(echo $migration | awk '{print $2}')
end

function migrate_down
  set migration (rake db:migrate:status 2>/dev/null | grep '\sup\s' --color=never | fzf --tac) || return

  rake db:migrate:down VERSION=(echo $migration | awk '{print $2}')
end

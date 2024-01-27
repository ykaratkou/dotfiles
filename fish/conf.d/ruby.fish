alias RED='RAILS_ENV=development'
alias REP='RAILS_ENV=production'
alias RET='RAILS_ENV=test'

alias rc='rails console'
alias rcs='rails console --sandbox'
alias rs='rails server'
alias rdm='rake db:migrate'
alias rdr='rake db:rollback'
alias rdms='rake db:migrate:status'
alias rr='rake routes'

alias rdr2='rake db:rollback STEP=2'
alias rdr3='rake db:rollback STEP=3'
alias rdr4='rake db:rollback STEP=4'

alias bu='bundle update'
alias bi='bundle install'

alias rd='reviewdog -diff="git diff master"'

# shortcut for running using ruby package manager
alias rspec='bundle exec rspec'

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

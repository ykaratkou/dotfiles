function define_bundle_context_functions --on-variable MAYBE_GEMFILE_COMMANDS
  for name in (string split : $MAYBE_GEMFILE_COMMANDS)
    function $name --wraps $name
      if test -e Gemfile -a (gem list "^($_)\$" -i) = true
        echo "Using Gemfile $_"
        command bundle exec $_ $argv
      else
        echo "Using global $_"
        command $_ $argv
      end
    end
  end
end

set -gx MAYBE_GEMFILE_COMMANDS rails:rake:sidekiq:cap:rspec:rubocop

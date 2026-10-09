alias dco='docker compose'
function dcl
  docker compose logs -f -n100 $argv[1]
end

function drun
  if test (count $argv) -lt 2
    echo "usage: drun <service> <alias> [args...]" >&2
    return 1
  end

  set -l service $argv[1]
  set -l name    $argv[2]
  set -l extra   $argv[3..-1]

  if not functions -q $name
    echo "drun: '$name' is not a fish function/alias" >&2
    return 1
  end

  set -l cmd (functions $name | string match -rg -- "--wraps='([^']*)'")
  if test -z "$cmd"
    echo "drun: could not resolve a command for '$name'" >&2
    return 1
  end

  docker compose run --rm -it $service (string split ' ' -- $cmd) $extra
end

function dweb --description 'drun with service=web' --wraps drun
    drun web $argv
end

function dharmony --description 'drun with service=web' --wraps drun
    drun harmony $argv
end

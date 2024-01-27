alias docker-compose='docker compose'
alias dco='docker-compose'
alias dstat='docker stats --format "table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}\t{{.NetIO}}\t{{.BlockIO}}"'

function dce
  set -l container_id (docker ps -q --filter name=$argv[1])
  set -l command "bash"

  if test -n "$argv[2]"
    set command "$argv[2]"
  end

  docker exec -it $container_id $command
end

function dcl
  set -l container_id (docker ps -q --filter name=$argv[1])
  docker logs -f -n100 $container_id
end


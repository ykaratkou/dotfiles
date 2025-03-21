function kbe
  set pod (kubectl get pods --no-headers --all-namespaces | fzf --tac) || return

  kubectl exec -it -n (echo $pod | awk '{print $1}') (echo $pod | awk '{print $2}') -- bash
end

function kbc
  set context (kubectl config get-contexts --output=name | fzf --tac) || return

  kubectl config use-context $context
end

function kbl
  set pod (kubectl get pods --no-headers --all-namespaces | fzf --tac) || return

  kubectl logs -f --since=5m -n (echo $pod | awk '{print $1}') (echo $pod | awk '{print $2}')
end

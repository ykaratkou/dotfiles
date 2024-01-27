function kbe
  set pod (kubectl get pods --no-headers --all-namespaces | fzf --tac) || return

  kubectl exec -it -n (echo $pod | awk '{print $1}') (echo $pod | awk '{print $2}') -- bash
end

function kbc
  set context (kubectl config get-contexts  --no-headers | fzf --tac) || return

  kubectl config use-context (echo $context | awk '{print $2}')
end

function kbl
  set pod (kubectl get pods --no-headers --all-namespaces | fzf --tac) || return

  kubectl logs -f --tail=100 -n (echo $pod | awk '{print $1}') (echo $pod | awk '{print $2}')
end

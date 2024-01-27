function fish_user_key_bindings
  fzf_key_bindings

  bind \cr 'history --merge ; fzf-history-widget'
end

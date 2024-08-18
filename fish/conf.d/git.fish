alias g='git'
alias gst='git status'
alias gd='git diff --color=always'
alias gm='git merge'

alias ga='git add'
alias gaa='git add --all'

alias gc='git commit -v'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcam='git commit -a -m'

alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'

alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'

alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout $(main_branch)'

alias grbm='git rebase $(main_branch)'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'

alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

alias glog='git log --oneline --decorate --graph --color=always'
alias gloga='git log --oneline --decorate --graph --all --color=always'

alias gsta='git stash save'
alias gstaa='git stash apply'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gstc='git stash clear'
alias gsts='git stash show --text'

alias gsh='git show --color=always'

#
# Will return the current branch name
# Usage example: git pull origin $(current_branch)
#
function current_branch
  begin
    git symbolic-ref HEAD; or \
    git rev-parse --short HEAD; or return
  end 2>/dev/null | sed -e 's|^refs/heads/||'
end

function main_branch
  git branch -r | grep -E -i '^\s.origin\/(master|main)' | cut -d/ -f2
end

alias ggpull='git pull origin (current_branch)'
alias ggpush='git push origin (current_branch)'

alias ggsup='git branch --set-upstream-to=origin/(current_branch)'
alias gpsup='git push --set-upstream origin (current_branch)'

alias ggpur='git pull --rebase origin (current_branch)'
alias ggpnp='git pull origin (current_branch); and git push origin (current_branch)'

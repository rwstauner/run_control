which dzil &> /dev/null || return

complete -W "installm $(dzil commands | awk -F : '/^ / { print $1 }')" dzil

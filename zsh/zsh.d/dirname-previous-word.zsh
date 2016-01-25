autoload -U modify-current-argument

_modify_arg_dirname () {
  REPLY="$1"
  if [[ "$1" = */* ]]; then
    # Put trailing slash back (also restricts to one at a time (won't go past a slash)).
    REPLY="${1%/*}/"
  fi
}

_dirname_prev_word () {
  modify-current-argument _modify_arg_dirname
}

zle -N _dirname_prev_word
bindkey "^[n" _dirname_prev_word

copy-prev-shell-word-dirname () {
  zle copy-prev-shell-word
  _dirname_prev_word
}

zle -N copy-prev-shell-word-dirname

bindkey "^[m" copy-prev-shell-word
bindkey "^[M" copy-prev-shell-word-dirname

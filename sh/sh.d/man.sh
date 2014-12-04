add_to_manpath () {
  dir="$1"
  [[ -d "$dir" ]] || return
  [[ -n "$MANPATH" ]] && MANPATH=":$MANPATH"
  export MANPATH="$dir${MANPATH/:$dir/}"
}

add_to_manpath $HOME/usr/share/man
add_to_manpath $HOME/homebrew/opt/coreutils/libexec/gnuman

umask 022

source_rc_files () {
  local rc
  for rc in "$@"; do
    [[ -f "$rc" ]] && [[ -r "$rc" ]] && source "$rc"
  done
}

# different semantics than the typical pathmunge()
add_to_path () {
  local after=false dir
  if [[ "$1" == "--after" ]]; then after=true; shift; fi
  for dir in "$@"; do
    if [[ -d "$dir" ]]; then
      if $after; then
        PATH="$PATH:"
        PATH="${PATH//$dir:/}$dir";
      else
        PATH=":$PATH"
        PATH="$dir${PATH//:$dir/}";
      fi
    fi
  done
}

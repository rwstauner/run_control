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

dedupe_path () {
  # Keep first occurrence and remove any duplicates.
  # Pass $PATH instead of using $ENV{PATH} since plenv will add to path.
  PATH=`perl -ne 'print join ":", grep { !$u{$_}++ } split /:/' <<<"$PATH"`
}

-rlwrap! () { local i; for i in "$@"; { alias $i=rlwrap\ $i; }; }

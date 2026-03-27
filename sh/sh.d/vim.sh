case "$EDITOR" in
  *nano)
    unset EDITOR;;
esac

if command -v nvim >/dev/null; then
  alias vim=nvim
  export EDITOR="${EDITOR:-nvim}"

  alias nvt='nvim +terminal'

  if [[ -n "$NVIM_LISTEN_ADDRESS" ]]; then
    alias nvim='nvr'
  fi
else
  export EDITOR="${EDITOR:-vim}"
fi

export FCEDIT="$EDITOR" VISUAL="$EDITOR"

alias vimXcat='ex -c w\ !\ cat -c :q'
alias :sp='vim'

function vim-qf {
  local qf=`mktemp`
  eval "capture-last-output >${ZSH_VERSION+!} '$qf'"
  vim -q "$qf" -c copen
  local ret=$?
  /bin/rm -f "$qf"
  return $ret
}

if command -v nvim >&-; then
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

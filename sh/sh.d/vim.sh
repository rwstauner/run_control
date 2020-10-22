alias vim=nvim

export EDITOR="${EDITOR:-nvim}"
export FCEDIT="$EDITOR" VISUAL="$EDITOR"

alias vimXcat='ex -c w\ !\ cat -c :q'
alias :sp='vim'

alias nvt='nvim +terminal'

if [[ -n "$NVIM_LISTEN_ADDRESS" ]]; then
  alias nvim='nvr'
fi

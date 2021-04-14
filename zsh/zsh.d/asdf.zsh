if [[ -n "$ASDF_DIR" ]]; then
  # append completions to fpath
  fpath=("$ASDF_DIR/completions" $fpath)
  # initialise completions with ZSH's compinit
  autoload -Uz compinit
  compinit
fi

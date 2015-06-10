RBENV_ROOT="$HOME/ruby/rbenv"

if [[ -d $RBENV_ROOT ]]; then
  export RBENV_ROOT

  add_to_path $RBENV_ROOT/bin

  eval "$(rbenv init -)"
fi

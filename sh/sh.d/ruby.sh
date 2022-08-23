RBENV_ROOT="$HOME/ruby/rbenv"

if [[ -d $RBENV_ROOT ]]; then
  export RBENV_ROOT

  add_to_path $RBENV_ROOT/bin

  eval "$(rbenv init -)"
fi

export DISABLE_SPRING=1
export RUBY_CONFIGURE_OPTS=--enable-shared

rbenv-gem-dir () {
  echo $(rbenv prefix)/lib/ruby/gems/*/gems/
}

alias ruby-ip='ruby -rsocket -e "puts Socket.gethostbyname(ARGV[0])[3].unpack(%(CCCC)).join(%(.))"'

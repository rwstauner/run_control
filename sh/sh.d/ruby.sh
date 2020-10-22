RBENV_ROOT="$HOME/ruby/rbenv"

if [[ -d $RBENV_ROOT ]]; then
  export RBENV_ROOT

  add_to_path $RBENV_ROOT/bin

  eval "$(rbenv init -)"
fi

export DISABLE_SPRING=1
export RUBY_CONFIGURE_OPTS=--enabled-shared

rbenv-gem-dir () {
  echo $(rbenv prefix)/lib/ruby/gems/*/gems/
}

# If a Gemfile has rb-readline, rails console is fine.
# Loading pry without rails requires including it directly.
alias pry='pry -rrb-readline'

alias ruby-ip='ruby -rsocket -e "puts Socket.gethostbyname(ARGV[0])[3].unpack(%(CCCC)).join(%(.))"'

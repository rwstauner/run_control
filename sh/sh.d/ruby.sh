RBENV_ROOT="$HOME/ruby/rbenv"

export RUBIES_DIR="$RBENV_ROOT/versions"

if [[ -n $ZSH ]]; then
  rubies=$RUBIES_DIR; : ~rubies
fi

if [[ -d $RBENV_ROOT ]]; then
  export RBENV_ROOT

  add_to_path $RBENV_ROOT/bin

  eval "$(rbenv init -)"
fi

export DISABLE_SPRING=1
export RUBY_CONFIGURE_OPTS=--disable-shared

chruby () {
  export RBENV_VERSION="$1"
}

alias extract-gem=~/run_control/ruby/extract-gem

rbenv-gem-dir () {
  echo $(rbenv prefix)/lib/ruby/gems/*/gems/
}

ruby-path () {
  local r="-r$1"
  case "$1" in
    -r*) r="$1"; shift;;
    -/)  r="-r${2%/*}"; shift;;
  esac
  RB="/$1.rb" ruby -W0 "$r" -e 'puts $".detect { |r| r.end_with?(ENV["RB"]) }'
}

vim_rb () {
  vim "$(ruby-path "$@")"
}

alias ruby-ip='ruby -rsocket -e "puts Socket.gethostbyname(ARGV[0])[3].unpack(%(CCCC)).join(%(.))"'

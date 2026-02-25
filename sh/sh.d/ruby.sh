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

_unset_ruby_env_vars () {
  unset RUBY_ROOT RUBY_ENGINE RUBY_VERSION GEM_ROOT GEM_HOME GEM_PATH BUNDLE_APP_CONFIG
}

# Overwrite chruby functions so dev doesn't force chruby into my shell.
chruby () {
  if [[ $# -eq 1 ]]; then
    echo export RBENV_VERSION="$1" 2>&1
    export RBENV_VERSION="$1"
  else
    rbenv versions
  fi
}
chruby_reset () {
  _unset_ruby_env_vars
  unset RBENV_VERSION
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

ruby () {
  # Respect RBENV_VERSION even if there other rubies earlier on the PATH.
  local ruby="${RBENV_VERSION+$RBENV_ROOT/shims/}ruby"

  [[ "$ruby" = ruby ]] && ruby="$(${BASH_VERSION+which}${ZSH_VERSION+${(s: :)${:-whence -p}}} ruby)"
  [[ "$ruby" = */rbenv/shims/ruby ]] && ruby="$(rbenv which ruby)"

  if [[ "$1" == --exe ]]; then
    exe=$2
    shift 2
    set -- $(ruby -e 'puts RbConfig::CONFIG["bindir"]')/$exe "$@"
    echo "$1" >&2
  fi

  case "$*" in
    # When using -v arg with ruby also print path to ruby.
    -v*|*\ -v*)
      echo "$ruby" >&2
      ;;
  esac

  (
    if [[ -n "$RBENV_VERSION" ]]; then
      _unset_ruby_env_vars
    fi
    # Prepend bindir to PATH to so that "bundler exec ruby" will invoke the right executable.
    PATH=${ruby%/*}:$PATH command "$ruby" "$@"
  )
}
for i in bundle gem; do
  # Go through the above function when using bundle command.
  alias $i="ruby --exe $i"
done

#!/bin/bash -e

# https://docs.ruby-lang.org/en/master/contributing/building_ruby_md.html

[[ -d .shadowenv.d ]] && shadowenv trust

branch="$(git branch --show-current 2> /dev/null | tr -d '\n' | tr -c 'a-zA-Z0-9_-' _)"
sha="$(git rev-parse --short HEAD)"
name=${NAME:-ruby-${branch:-$sha}}

# yes stats dev dev_nodebug
yjit=yes

# yes
zjit=yes

config="${1#ruby-}"
case "$config" in
  install)
    # default name and config, pass through
    ;;
  # [m]aster or [b]ranch
  [mb]dev|[mb]stats)
    shift
    jit_config=${config#[mb]}
    name=ruby-$config yjit=$jit_config zjit=$jit_config
    ;;
  [a-z]*)
    shift
    name=ruby-$config
    ;;
esac
unset config

install=false
if [[ "$1" == install ]]; then
  install=true
  shift
fi

opts=(
  --disable-install-doc
  --disable-shared
  --enable-compile-commands

  #--enable-debug-env optflags="-O0 -fno-omit-frame-pointer"

  # optflags=-O0
  #cppflags=-DRUBY_DEBUG

  # --enable-rjit=dev
  ${yjit+--enable-yjit=}$yjit
  ${zjit+--enable-zjit=}$zjit
)

if [[ `uname` = Darwin ]]; then
  brew_pkgs=(
    # jemalloc
    # gmp
    openssl@3
    # readline
    # libyaml
    # zlib
  )
  PATH="$(brew --prefix m4)/bin:$(brew --prefix bison)/bin:$PATH"
  for ext in "${brew_pkgs[@]}"; do
    opts+=("--with-${ext%@*}-dir=$(brew --prefix $ext)")
  done
fi

# for ruby < 3.2
# export PKG_CONFIG_PATH=/opt/homebrew/Cellar/openssl@1.1/1.1.1u/lib/pkgconfig
# export LIBRARY_PATH=/opt/homebrew/Cellar/openssl@1.1/1.1.1u/lib
# export CPATH=/opt/homebrew/Cellar/openssl@1.1/1.1.1u/include
# export CPPFLAGS=-I/opt/homebrew/Cellar/openssl@1.1/1.1.1u/include
# export LDFLAGS=-L/opt/homebrew/Cellar/openssl@1.1/1.1.1u/lib

verbose () {
  echo "$ $*"
  "$@"
}

src_dir=$PWD
build () {
  build_dir=$HOME/src/ruby/builds/${name#ruby-}
  mkdir -p $build_dir && cd $build_dir
  pwd
  if ! do-make "$@"; then
    rm -f config.cache
    do-make "$@"
  fi

  echo
  echo "compiled for $prefix with:"
  echo "${opts[*]} $CONFIGURE_ARGS $*"
  echo
  echo "built $name"
  pwd
}

do-make () {
  prefix="${HOME}/.rubies/$name"
  test -f $src_dir/configure || $src_dir/autogen.sh
  verbose $src_dir/configure -C --prefix="$prefix" "${opts[@]}" $CONFIGURE_ARGS "$@"
  verbose make tags
  verbose make -j
  $install && verbose make install
}

build "$@"

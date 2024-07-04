#!/bin/bash -e

# https://docs.ruby-lang.org/en/master/contributing/building_ruby_md.html

[[ -d .shadowenv.d ]] && shadowenv trust

branch="$(git current-branch 2> /dev/null | tr -d '\n' | tr -c 'a-zA-Z0-9_-' _)"
sha="$(git rev-parse --short HEAD)"
name=${NAME:-ruby-${branch:-$sha}}

autoreconf -i

# yes stats dev dev_nodebug
yjit=yes #dev_nodebug

opts=(
  --disable-install-doc
  --disable-shared
  --enable-compile-commands

  # optflags=-O0
  #cppflags=-DRUBY_DEBUG

  # --enable-rjit=dev
  ${yjit+--enable-yjit=}$yjit
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

build () {
  prefix="${HOME}/.rubies/$name"

  verbose ./configure -C --prefix="$prefix" "${opts[@]}" $CONFIGURE_ARGS "$@"
  verbose make -j

  echo
  echo "compiled to $prefix with:"
  echo "${opts[*]} $CONFIGURE_ARGS $*"
  echo
  echo "built $name"
}

build || { git clean -fdX && build; }

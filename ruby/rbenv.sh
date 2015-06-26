#!/bin/bash

RBENV_ROOT="$HOME/ruby/rbenv"

sync () {
  local repo="$1" dir="$2"
  printf "%-55s ... " "$repo"
  if ! [[ -d "$dir/.git" ]]; then
    git clone "$repo" "$dir"
  else
    (cd "$dir"; git pull)
  fi
}

plugin () {
  local repo="$1"
  sync https://github.com/${repo}.git "${RBENV_ROOT}/plugins/${repo#*/}"
}

symlink () {
  local src="$1" dest="$2"
  [[ -d "$dest" ]] && dest="$dest/${src##*/}"
  [[ -h "$dest" ]] || \
    ln -s "$src" "$dest"
}

# Main

sync https://github.com/sstephenson/rbenv.git $RBENV_ROOT


# Plugins

plugin sstephenson/ruby-build
plugin sstephenson/rbenv-default-gems
plugin sstephenson/rbenv-gem-rehash
plugin rkh/rbenv-update
plugin rkh/rbenv-whatis
plugin rkh/rbenv-use

# Poor man's each: rbenv versions --bare | while read v; do RBENV_VERSION=$v rbenv exec ruby -e '...'; done
# previously chriseppstein/rbenv-each
plugin rbenv/rbenv-each


# Link version-controlled default-gems so rbenv plugin sees it.
symlink $HOME/ruby/rc/default-gems $RBENV_ROOT/

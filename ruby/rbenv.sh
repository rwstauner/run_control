#!/bin/bash

RBENV_ROOT="$HOME/ruby/rbenv"

sync () {
  local repo="$1" dir="$2"
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

# Install plugins:
PLUGINS=(
  sstephenson/ruby-build
  sstephenson/rbenv-default-gems
  sstephenson/rbenv-gem-rehash
  rkh/rbenv-update
  rkh/rbenv-whatis
  rkh/rbenv-use
)

sync https://github.com/sstephenson/rbenv.git $RBENV_ROOT

for plugin in "${PLUGINS[@]}"; do
  plugin "$plugin"
done

# Link version-controlled default-gems so rbenv plugin sees it.
symlink $HOME/ruby/rc/default-gems $RBENV_ROOT/

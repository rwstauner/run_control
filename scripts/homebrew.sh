#!/bin/sh

homebrew=$HOME/homebrew
brewbin=$homebrew/bin

git clone http://github.com/Homebrew/homebrew $homebrew

symlink () {
  local src="$1" dest="$2"
  test -h "$dest" || \
    ln -s "$src" "$dest"
}

brew install coreutils

brew install gawk
# gawk installs awk symlink

brew install gnu-sed
symlink gsed $brewbin/sed

brew install tmux

# Get newer version with more consistent config.
brew install vim

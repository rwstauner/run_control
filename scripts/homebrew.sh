#!/bin/sh

homebrew=$HOME/homebrew
brewbin=$homebrew/bin

test -d $homebrew/.git || \
git clone http://github.com/Homebrew/homebrew $homebrew

symlink () {
  local src="$1" dest="$2"
  test -h "$dest" || \
    ln -s "$src" "$dest"
}

# Get latest formulae.
brew update

# Since coreutils doesn't support --with-default-names we add to path in sh/loader.sh
brew install coreutils

brew install gawk
# gawk installs awk symlink

# Get version 2+.
brew install git

brew install --with-default-names gnu-sed

# If imagemagick has removed the version in the formula:
# SHA256=foobar URL=yo perl -p -i -e 's/(^\s+(sha256|url)\s+").+?(")/$1$ENV{"\U$2"}$3/' Library/Formula/imagemagick.rb
brew install imagemagick --with-x11

brew install jq

#brew install imagesnap
#brew install tlassemble

brew install pstree

brew install tmux
brew install tree

# Get newer version with more consistent config.
brew install vim

brew install wget

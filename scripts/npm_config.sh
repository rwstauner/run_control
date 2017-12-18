#!/bin/bash

config () {
  npm config set "$1" "$2" --global
}

[[ -w `which node` ]] || \
config prefix $HOME/node/global

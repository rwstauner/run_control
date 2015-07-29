#!/bin/bash

config () {
  npm config set "$1" "$2" --global
}

config prefix $HOME/node/global

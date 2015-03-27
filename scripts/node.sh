#!/bin/bash

. `dirname "$0"`/.helpers.sh
umask 0077

install_iojs () {
  url="https://iojs.org/dist/latest/"
  archive=`curl "$url" | perl -lne 'print $1 if /href="(iojs-.+?linux-x64\.tar\.xz)"/'`
  basename="${archive%.tar.*}"
  parent="$HOME/usr"
  symlink="$parent/iojs"

  if ! [[ -d "$parent/$basename" ]]; then
    # Write to disk instead of pipe to utilize `tar -a`.
    curl -O "$url/$archive" && \
    tar -xaf "$archive" -C "$parent" && \
    rm "$symlink" && ln -s "$basename" "$symlink" && \
    rm "$archive"
  fi
}

setup_runtime_dir node

mkdir -p ~/node/global

install_iojs

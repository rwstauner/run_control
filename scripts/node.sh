#!/bin/bash

. `dirname "$0"`/.helpers.sh
umask 0077

# https://iojs.org/dist/latest/
# curl https://iojs.org/dist/latest/ | perl -lne 'print $1 if /href="(iojs-.+?linux-x64\.tar\.xz)"/'

setup_runtime_dir node

mkdir -p ~/node/global

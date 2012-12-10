#!/bin/bash

# lesskey takes input and dumps binary output into ~/.less

cat <<LESSKEY | lesskey -
#command

  # for consistency with vim, tmux, etc
  # ctrl-up
[1;5A   back-line
  # ctrl-down
[1;5B   forw-line

LESSKEY

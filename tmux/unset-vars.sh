#!/bin/bash

# It's handy to set vars in tmux conf files for interpolation
# but we don't need them to persist in the global env.
# Assume that lower-case vars can be unset (allow upper case vars to persist).
perl -lne 'print "tmux setenv -g -u $1" if /^([a-z0-9_]+)=/' \
  ~/.tmux.conf ~/run_control/tmux/*.conf | sh

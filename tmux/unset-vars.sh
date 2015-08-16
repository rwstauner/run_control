#!/bin/bash

# It's handy to set vars in tmux conf files for interpolation
# but we don't need them to persist in the global env.
perl -lne 'print "tmux setenv -g -u $1" if /^(\w+)=/' \
  ~/.tmux.conf ~/run_control/tmux/*.conf | sh

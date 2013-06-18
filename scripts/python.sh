#!/bin/bash

pydir=$HOME/python
test -d "$pydir" || mkdir "$pydir"

pyrc=$pydir/rc
if ! [[ -d $pyrc ]]; then
  ln -s ~/run_control/python $pyrc;
fi

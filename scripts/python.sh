#!/bin/bash

umask 0077
pydir=$HOME/python
test -d "$pydir" || mkdir "$pydir"

pyrc=$pydir/rc
if ! [[ -d $pyrc ]]; then
  ln -s ~/run_control/python $pyrc;
fi

pyver=`python -V 2>&1 | cut -d ' ' -f 2`

if echo "$pyver" | grep -qE '[0-9]+\.[0-9]+\.[0-9]+'; then
  echo "Python: $pyver"
else
  echo 'Failed to get python version' 1>&2
  exit 1
fi

# TODO: get-pip and/or install virtualenv if not already installed

venv=$pydir/venv/$pyver
venv_local=$pydir/venv/local
activate=$venv/bin/activate

if ! [[ -e "$activate" ]]; then
  virtualenv $venv
fi

test -h $venv_local || ln -s $pyver $venv_local

#test -f $activate && . $activate && \
  #pip install -r $pyrc/requirements.txt

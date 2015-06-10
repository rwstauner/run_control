#!/bin/bash

. `dirname "$0"`/.helpers.sh
umask 0077

setup_runtime_dir ruby

$HOME/ruby/rc/rbenv.sh

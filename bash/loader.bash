rc_dir=$HOME/run_control

source $rc_dir/sh/loader.sh

# source global definitions
source_rc_files /etc/bash.bashrc /etc/bashrc

# load the rest
bashrc_dir=$rc_dir/bash
source_rc_files $bashrc_dir/bash.d/* ~/.bashrc.local $EXTRA_BASHRC

# completion after the others (so PATH is built, etc)
source_rc_files $bashrc_dir/completion.d/contrib/* $bashrc_dir/completion.d/*

unset rc_dir bashrc_dir

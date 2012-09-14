shopt -s extglob progcomp
complete -d pushd cd

if [ -z "$BASH_COMPLETION" ]; then
  bc_etc=/etc/bash_completion
  bc_user=$HOME/.bashrc.d/completion.d/.borrowed
  if [ -f $bc_etc ]; then
    . $bc_etc
  elif [ -f $bc_user ]; then
    . $bc_user
    source_rc_files ~/.bashrc.d/completion/.borrowed.d/*
  fi
  unset bc_etc bc_user
fi

# custom completions
source_rc_files ~/.bashrc.d/completion/*

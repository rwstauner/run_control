shopt -s extglob progcomp
complete -d pushd cd

if [ -z "$BASH_COMPLETION" ]; then
  bc_etc=/etc/bash_completion
  if [ -f $bc_etc ]; then
    . $bc_etc
  fi
  unset bc_etc
fi

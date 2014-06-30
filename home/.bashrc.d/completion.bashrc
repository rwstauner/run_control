shopt -s extglob progcomp
complete -d pushd cd

# Something chews this variable down the line but since I haven't found
# what/where put it in a function I can call to fix things when I need it.
_fix_comp_wordbreaks () {
  # Ignore characters that I don't use in filenames.
  #COMP_WORDBREAKS=$' \t\n"\'><;|&(:'
  #COMP_WORDBREAKS=$' \t\n"\'><=;|&(:'
   COMP_WORDBREAKS=$' \t\n"\'><=;|&(:@'
}

_fix_comp_wordbreaks

if [ -z "$BASH_COMPLETION" ]; then
  bc_etc=/etc/bash_completion
  if [ -f $bc_etc ]; then
    . $bc_etc
  fi
  unset bc_etc
fi

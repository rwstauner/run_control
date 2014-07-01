export TAR_OPTIONS="$TAR_OPTIONS --exclude-from=$HOME/.excludes"

if [[ -z "$LS_COLORS" ]]; then
  if which dircolors &> /dev/null; then
    eval `dircolors`
    if [[ -r ~/.dircolors ]]; then
      _def_ls_colors="$LS_COLORS"
      eval `dircolors ~/.dircolors`
      export LS_COLORS="${_def_ls_colors}$LS_COLORS"
      unset _def_ls_colors
    fi
  fi
fi

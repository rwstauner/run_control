# Colorize different file types with ls, etc.

if [[ -z "$LS_COLORS" ]]; then
  if which dircolors &> /dev/null; then
    # Get the system defaults.
    eval `dircolors`
    if [[ -r ~/.dircolors ]]; then
      # Preserve previous colors (eval `dircolors` will overwrite).
      _def_ls_colors="$LS_COLORS"
      # Get local customizations.
      eval `dircolors ~/.dircolors`
      # Append local customizations to system defaults.
      export LS_COLORS="${_def_ls_colors}$LS_COLORS"
      unset _def_ls_colors
    fi
  fi
fi

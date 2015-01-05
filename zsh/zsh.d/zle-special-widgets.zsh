# Zle widgets overwrite when redefined
# so in order to utilize multiple features we need to redefine the widgets
# at the end in order to execute all the desired functionality.

_gen_special_widget () {

  local i widget="$1" name="_all_${1//-/_}"; shift
  local -a lines
  lines=("$name () {"  "$@"  "}")

  for (( i=1; i <= ${#lines}; ++i )) do
    # DRY the logic for only calling defined functions.
    if [[ "${lines[$i]}" =~ '^[a-z_-]+\(\)$' ]]; then
      # Make sure it's defined (ignore the trailing "()").
      if (( ${+functions[${lines[$i]%??}]} )); then
        lines[$i]="${lines[$i]%\(\)} \"\$@\""
      # else just remove it.
      else
        lines[$i]=''
      fi
    fi
  done

  # Join by newlines (use g:: to process "\n").
  eval "${(g::)${(j:\n:)lines}}"
  # Tell zle to assign the widget to this function.
  zle -N "$widget" "$name"
  # If there's a function left-over by this name it won't be used.
  unset -f "$widget"

}

zmodload zsh/terminfo

() {

  local name='zle-line-init'
  local -a lines

  # Set application mode so terminfo values are valid.
  (( ${+terminfo[smkx]} )) && lines+='echoti smkx'

  lines+=(

    # vim-emacs switching
    '_vim_emacs_line_init()'

    # Syntax-highlighting loops to wrap predefined widgets
    # but duplicating that is complicated so cheat by just calling the functions.
    # ohmyzsh safe-paste
    '_zle_line_init()'

    # zsh-syntax-highlight
    '_zsh_highlight()'

  )

  _gen_special_widget "$name" "${lines[@]}"


  name='zle-line-finish'
  lines=()

  # Reset application mode.
  (( ${+terminfo[rmkx]} )) && lines+='echoti rmkx'

  lines+=(

    # ohmyzsh safe-paste
    '_zle_line_finish()'

    # zsh-syntax-highlighting
    '_zsh_highlight()'

  )

  _gen_special_widget "$name" "${lines[@]}"

}

# Don't need this anymore.
unset -f _gen_special_widget

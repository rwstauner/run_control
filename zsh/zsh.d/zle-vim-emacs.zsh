# Switch from vi-cmd mode to emacs keymap (instead of viins) naturally.

# Called when keymap changes (from vicmd to viins, for example).
zle-keymap-select () {
  if [[ $KEYMAP == vicmd ]]; then
    # Make it apparent that we've switched to vicmd mode.
    PREDISPLAY=':'
  else
    # Use emacs mode rather than plain viins.
    PREDISPLAY=' '
    zle -K emacs
  fi
  #RPROMPT=$KEYMAP
  #zle reset-prompt
}

zle-line-init () {
  # Take up the same width as when the colon is present.
  PREDISPLAY=' '
}

zle -N zle-line-init
zle -N zle-keymap-select

bindkey -e "\e" vi-cmd-mode

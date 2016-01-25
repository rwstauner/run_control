# Switch from vi-cmd mode to emacs keymap (instead of viins) naturally.

# Called when keymap changes (from vicmd to viins, for example).
_vim_emacs_keymap_select () {
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

_vim_emacs_line_init () {
  # Take up the same width as when the colon is present.
  PREDISPLAY=' '
  #zle reset-prompt
  #zle redisplay
  zle -R
}

zle -N zle-line-init     _vim_emacs_line_init
zle -N zle-keymap-select _vim_emacs_keymap_select

# Default is ^X^V but a plain ^[ makes it feel like vim.
bindkey -e "\e" vi-cmd-mode

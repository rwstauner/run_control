# Line editing!
setopt zle

# Remember `bindkey -L` to print out current mappings.

# Give a a key binding to switch between emacs and vi mode.
switch-keymaps () {
  if [[ $KEYMAP != vicmd ]]; then
    # Switch to vicmd mode and make it apparent.
    PREDISPLAY=': '
    region_highlight=('P0 1 standout')
    zle -K vicmd
  else
    # Use emacs mode rather than plain viins.
    PREDISPLAY=''
    region_highlight=()
    zle -K emacs
  fi
}
zle -N switch-keymaps
bindkey -e "\e\e" switch-keymaps
bindkey -a "\e\e" switch-keymaps
# This seems to need to be rebound.
bindkey -v "\e"   vi-cmd-mode
# TODO: better would be to intercept vi-insert-mode and switch to emacs.

# Start in emacs mode (so many more key bindings up front).
bindkey -e

# Incremental is cool, but doesn't return many suggestions.
# autoload -U incremental-complete-word
# zle -N incremental-complete-word

# Insert files shows the results I'd like to see for incremental.
# autoload -U insert-files
# zle -N insert-files

# Prediction is cool, but toggling on/off is not easy/intuitive.
# The up/down history search is probably easier/more useful.
autoload -U predict-on
zle -N predict-on
zle -N predict-off

predict-toggle () {
  if [[ -z "$ZLE_PREDICT" ]]; then
    predict-on
    # TODO: get prompt to update and show this (or a string).
    ZLE_PREDICT='✨'
  else
    predict-off
    unset ZLE_PREDICT
  fi
}
zle -N predict-toggle
bindkey "\e+" predict-toggle


# This menu is nifty, maybe I'll try it someday.
# autoload -Uz history-beginning-search-menu
# zle -N history-beginning-search-menu
# bindkey '\eP' history-beginning-search-menu


# Other functions to try:
# modify-current-argument
# url-quote-magic
# quote-and-complete-word
# replace-string


# Comment line instead of executing or eliminating.
bindkey "\e#" pound-insert


# Up/Down searches history matching the text before the cursor.
# https://coderwall.com/p/oqtj8w
# See https://github.com/zsh-users/zsh-history-substring-search for an alternate implementation.
bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward

# The following will do the same but put the cursor at the end of the line.
# That's consistent with bash/readline when you press up with no prefix
# but that sometimes gets me into trouble; maybe the extra key press isn't bad.
# autoload -Uz history-search-end
# zle -N history-beginning-search-backward-end history-search-end
# zle -N history-beginning-search-forward-end  history-search-end
# bindkey "\e[A" history-beginning-search-backward-end
# bindkey "\e[B" history-beginning-search-forward-end


# Bring back a few things from readline.
bindkey "^U" backward-kill-line


# Help
bindkey "\e^V" describe-key-briefly
bindkey "\e\`" which-command

# Like vim's :
bindkey "\e:"  execute-named-cmd


# Keys to remember:

# Esc-Q   push-line: stash, run different command, come back to previous (unfinished)
# Esc-M   copy-prev-shell-word: OMZ sets this
# Esc-.   insert-last-word
# ^@      set-mark-command: mark cursor position for region edit
# ^X^E    edit-command-line
# Esc-A   accept-and-hold: run, then bring up again

# TODO: put Esc-? functionality into prompt?
# TODO: Create function (omz plugin?) to display cheat sheet of zle commands.
# TODO: is there a quote-this-word function?


# To change word-style for all functions:
#autoload -Uz select-word-style
#select-word-style normal

# Move/Kill shell words (better than non-blank regions) backward and forward.
() {
  local direction action prefix match_fun
  for direction in backward forward; do
    for action in '' 'kill'; do
      prefix="${direction}${action:+-}${action}"
      # Set word-style for our widget.
      zstyle ":zle:${prefix}-shell-word" word-style shell
      # (There is no "forward-kill-*" it's just "kill-*".)
      match_fun="${prefix//forward-kill/kill}-word-match"
      # (Functions autoloaded by select-word-style aren't named *-match.)
      autoload -Uz "$match_fun"
      # Alias our widgets to the magic *-match functions (which use the style).
      zle -N "${prefix}-shell-word" "$match_fun"
    done
  done
}

bindkey "\e[" backward-kill-shell-word
bindkey "\e]"  forward-kill-shell-word

# Ctrl-arrow  moves across words ($WORDCHARS).
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C"  forward-word

# Shift-arrow moves across shell words.
# TODO: use terminfo?
bindkey "\e[1;2D" backward-shell-word
bindkey "\e[1;2C"  forward-shell-word

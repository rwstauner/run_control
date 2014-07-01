bindkey -e

# Line editing!
setopt zle

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


# Comment line instead of executing or eliminating.
bindkey "\e#" pound-insert


# Up/Down searches history matching the text before the cursor.
# https://coderwall.com/p/oqtj8w
bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward


# Bring back a few things from readline.
bindkey "^U" backward-kill-line


# Ctrl-arrow  moves across words (small words).
# Shift-arrow moves across non-blank words.
bindkey "\e[1;2D" vi-backward-blank-word
bindkey "\e[1;2C" vi-forward-blank-word


# Help
bindkey "\e^V" describe-key-briefly
bindkey "\e!"  which-command

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
# TODO: use `bindkey -s` to do something like `mark, move-non-blank, kill`?
# TODO: is there a quote-this-word function?

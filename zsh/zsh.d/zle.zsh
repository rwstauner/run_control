# Line editing!
setopt zle

_bell () { echo -n "\a"; }
zle -N _bell

zmodload zsh/terminfo

# Time to wait (in hundredths of seconds) for bound multi-char sequences.
# Default is 4.
export KEYTIMEOUT=2

# Remember `bindkey -L` to print out current mappings.

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
# url-quote-magic
# quote-and-complete-word
# replace-string


# Comment line instead of executing or eliminating.
bindkey "\e#" pound-insert


# Up/Down searches history matching the text before the cursor.
# https://coderwall.com/p/oqtj8w
# See https://github.com/zsh-users/zsh-history-substring-search for an alternate implementation.
bindkey "$terminfo[kcuu1]" history-beginning-search-backward
bindkey "$terminfo[kcud1]" history-beginning-search-forward

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


# Removing the next word (especially the first on a line) is super helpful...
# bind a control-based shortcut for maximum ease (especially on the mac).
bindkey "^B" kill-word
# Bell to remind me to stop using it (removing it confuses the next sequence).
bindkey "\ed" _bell


# Help
bindkey "\e^V" describe-key-briefly
bindkey "\e\`" which-command

# Like vim's :
bindkey "\e:"  execute-named-cmd


# Keys to remember:

# Esc-Q   push-line: stash, run different command, come back to previous (unfinished)
# Esc-.   insert-last-word # (from previous history event)
# ^@      set-mark-command: mark cursor position for region edit
# ^X^E    edit-command-line # (in $EDITOR)
# ^X^B    vi-match-bracket
# Esc-t   transponse-words
# Esc-X   execute-named-cmd # prompt for zle widget name and execute

# More than just Enter:
bindkey "^[a"   accept-and-hold
bindkey "^[b"   accept-and-infer-next-history
bindkey "^X^M"  accept-and-infer-next-history

# Show indicator between ^V and key.
bindkey "^V" vi-quoted-insert

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

bindkey '^X^W' backward-kill-shell-word
bindkey '^X^B'  forward-kill-shell-word

# Ctrl-arrow  moves across words ($WORDCHARS).
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C"  forward-word

# Ctrl-Shift-arrow moves across shell words.
# TODO: use terminfo?
bindkey "\e[1;6D" backward-shell-word
bindkey "\e[1;6C"  forward-shell-word

# Edit the current command line in $EDITOR.
autoload -Uz edit-command-line
zle -N edit-command-line
#bindkey -M vicmd v edit-command-line
bindkey '^X^E' edit-command-line


# Composed chars (for when xmodmap isn't there to map Super key for me).
autoload -Uz insert-composed-char
zle -N insert-composed-char
bindkey '^Xc' insert-composed-char

# Hit the key, type the hexadecimal, hit the key again.
autoload -Uz insert-unicode-char
zle -N insert-unicode-char
bindkey '^Xu' insert-unicode-char

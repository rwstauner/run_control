# The docs say to load this after the syntax highlighter.

source_rc_file "$ZSH/plugins/history-substring-search/history-substring-search.zsh" || return

# Alter the keybindings.

# Use plain up/down for beginning search.
# (Configured later in zle.zsh)

# Use ctrl up/down for substring search.
# (I'm not sure there's a terminfo entry for this.)
bindkey "^[[1;5A" history-substring-search-up
bindkey "^[[1;5B" history-substring-search-down

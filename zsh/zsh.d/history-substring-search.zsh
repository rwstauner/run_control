# The docs say to load this after the syntax highlighter.

source "$ZSH/plugins/history-substring-search/history-substring-search.zsh" || return

# Alter the keybindings.

# Use the default up/down for beginning search.
# (The history substring plugin defines keys using terminfo like this.)
bindkey "$terminfo[kcuu1]" history-beginning-search-backward
bindkey "$terminfo[kcud1]" history-beginning-search-forward

# Use ctrl arrow for substring search.
# (I'm not sure there's a terminfo entry for this.)
bindkey "^[[1;5A" history-substring-search-up
bindkey "^[[1;5B" history-substring-search-down

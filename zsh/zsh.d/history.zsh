# Append history so that parallel shells all get theirs in.
setopt append_history

setopt extended_history

# Ignore all duplicate history entries (not just the previous command).
#setopt hist_expire_dups_first
#setopt hist_ignore_dups
#setopt hist_save_no_dups
setopt hist_ignore_all_dups

# Don't save commands with leading space into history.
setopt hist_ignore_space
# When editing history commands let me confirm it.
setopt hist_verify
# Save history incrementally instead of at shell exit.
setopt inc_append_history

setopt share_history # share command history data

HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=$HISTSIZE

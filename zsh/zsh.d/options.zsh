# Configuration utility:
#   autoload zsh-newuser-install
#     zsh-newuser-install -f

bindkey -e

# zshoptions(1)

unsetopt menu_complete
unsetopt rec_exact

setopt always_to_end

unsetopt auto_cd
unsetopt auto_name_dirs
unsetopt auto_pushd
unsetopt cdable_vars

setopt complete_in_word

unsetopt flow_control

# Error if glob doesn't match.  Use glob*(N) to override.
setopt nomatch

setopt interactive_comments

setopt pushd_minus

setopt rematch_pcre

# Line editing!
setopt zle

# autoload -U compinit
# compinit
# autoload -U incremental-complete-word
# zle -N incremental-complete-word
# autoload -U insert-files
# zle -N insert-files
# autoload -U predict-on
# zle -N predict-on

# keys
# Esc-Q (stash, run different command, come back to previous (unfinished))
# Esc-A (run, then bring up again)

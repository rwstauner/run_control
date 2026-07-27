# Configuration utility:
#   autoload zsh-newuser-install
#     zsh-newuser-install -f

# zshoptions(1)

unsetopt menu_complete
unsetopt rec_exact

setopt always_to_end

unsetopt auto_cd
unsetopt auto_name_dirs
unsetopt auto_pushd
unsetopt cdable_vars

# Error on dangerous overwrite attempts (shell redirection).
# I'm not settled on this, but I'll try it for a while.
unsetopt clobber

unsetopt flow_control

# Perform filename expansion on the RHS of "FOO=~bar".
setopt magic_equal_subst

# Error if glob doesn't match.  Use glob*(N) to override.
setopt nomatch

# Ignore Ctrl-D, require "exit" or "logout".
#setopt ignore_eof

setopt interactive_comments

setopt pushd_minus

# perl!
setopt rematch_pcre

# Print timing statistics for commands that take longer than this.
REPORTTIME=10
# Print commands with RSS in kb greater than this.
REPORTMEMORY=10000000
# Default is '%J  %U user %S system %P cpu %*E total'.
# Appending ' max RSS %M' will show RSS.
TIMEFMT='%J  %U user %S system %P cpu %*E total max RSS %M'

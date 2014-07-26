# /usr/share/zsh/function

# Calendar/age: Match file age with a glob.
# print *(e:age 2006/10/04 2006/10/09:)
autoload -Uz age

# Exception handling
autoload -Uz catch

# Version comparison.
autoload -Uz is-at-least

# Like zargs but useful for globs that match too many files.
autoload -Uz zargs

# Calculator alternative to bc.
autoload -Uz zcalc

# No other shell could do this.
# Edit small files with the command line editor.
# Use ^X^W to save, ^C to abort.
# Option -f: edit shell functions.  (Also if called as fned.)
autoload -Uz zed

# Rename files (like the perl rename command) but with zsh patterns.
# Can be linked to zcp and zln.
autoload -Uz zmv

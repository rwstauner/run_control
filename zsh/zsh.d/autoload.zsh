# /usr/share/zsh/function

# Calendar/age: Match file age with a glob.
# print *(e:age 2006/10/04 2006/10/09:)
autoload -Uz age

# Exception handling
autoload -Uz catch

# Calculator alternative to bc.
autoload -Uz zcalc

# No other shell could do this.
# Edit small files with the command line editor.
# Use ^X^W to save, ^C to abort.
# Option -f: edit shell functions.  (Also if called as fned.)
autoload -Uz zed

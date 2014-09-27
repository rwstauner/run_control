alias help=run-help


# The built-in history is `fc -l` but that only shows 10.  Show all of them.
# ...but use a pager because otherwise that will wipe out my scrollback.
'history' () { fc -l 1 | $PAGER; }

# -v verbose
# -c differently verbose
# -f show code for functions
# -s resolve symlinks for paths
alias type='whence -vcfs'

# putting color in GREP_OPTIONS makes it work for (b)zgrep, too
# but is deprecated, apparently.
# export GREP_OPTIONS="--color=auto"
alias grep='grep --color=auto'

# GNU grep
export GREP_COLORS="ms=01;31:mc=01;33:sl=:cx=34:fn=35:ln=32:bn=32:se=36"

# http://savannah.gnu.org/bugs/index.php?31389
#alias grep='env LC_ALL=POSIX grep'

# Pipe requires shift but fingers are too fast/slow.
alias Grep='grep'

# Alias to show line number to make it easy to use as a vim quickfix buffer.
# Use a separate alias rather than `grep` or `GREP_OPTIONS` since so many things
# use grep that might not be expecting altered output.
# Also force display of filename for consistency.
alias grepn='grep -H -n'

# RIPGREP_CONFIG_PATH
# alias rg='rg -H --no-heading --vimgrep'
alias rg='rg -H --no-heading'

# putting color in GREP_OPTIONS makes it work for (b)zgrep, too
# Always show line number to make it easy to use as a vim quickfix buffer.
GREP_OPTIONS="--color=auto --line-number"

GREP_COLORS="ms=01;31:mc=01;33:sl=:cx=34:fn=35:ln=32:bn=32:se=36"
export GREP_OPTIONS GREP_COLORS

# http://savannah.gnu.org/bugs/index.php?31389
#alias grep='env LC_ALL=POSIX grep'

# Pipe requires shift but fingers are too fast/slow.
alias Grep='grep'

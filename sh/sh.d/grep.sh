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

# RIPGREP_CONFIG_PATH could point to a file of command line args... useful for --type-add 'foo:*foo'
# Finding 4421 results in 114084 files causes rg's --sort (single-threaded)
# to double response time (from 1m to 2m), whereas using |sort is nominal.
rg () {
  # On darwin the pipline inside the case statement confuses tmux
  # and the pane_current_path is lost.
  # Using a subshell works around that.
  local i;
  for i in "$@"; do
    case "$i" in
      -h|--help)
        (command rg "$@" | $PAGER)
        return $?;;
      -l)
        set -- --color=never "$@";;
    esac
  done
  (command rg --pretty -H --no-heading "$@" | rg-sort "$@" | $PAGER)
}

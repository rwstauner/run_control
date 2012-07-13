GREP_OPTIONS="--color=auto"
GREP_COLORS="ms=01;31:mc=01;33:sl=:cx=34:fn=35:ln=32:bn=32:se=36"
export GREP_OPTIONS GREP_COLORS

alias grep='env LC_ALL=POSIX grep --color=auto'
alias Grep='grep'
alias zgrep='zgrep --color=auto'

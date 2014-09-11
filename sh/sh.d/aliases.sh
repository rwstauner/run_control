# aliases (hooray!)

# interactive (confirmation prompt)
for i in rm mv cp;
  { alias $i="$i -iv"; }

# verbose
for i in rmdir mkdir rename;
  { alias $i="$i -v"; }

# let me use my aliases when delaying commands
for i in xargs watch sudo;
  { alias $i="$i "; }

# add readline support
for i in pacmd;
  { alias $i="rlwrap $i"; }

# shortcuts for common args

alias caly='cal `date +%Y`'

alias diffpatch='diff -uprN'
alias diffgit='git diff --no-index'
alias diffgitcw='git diff --no-index --color-words=.'

alias ftp='/usr/bin/ftp'; # kerberos ftp bothers me

# sometimes my finger can't let go of the shift key used to make the pipe
alias Wc=wc

# ls
alias ls='ls --color=auto'
alias ll='ls -l'
alias lf='ll -aF'
alias lh='lf -h'
alias lft='lf --time-style=full-iso'

# show child process hierarchy with indentation
alias ps='ps -H'

# Always use a pager.
for i in dict; {
  eval "$i"' () { command '"$i"' "$@" | $PAGER; }'
}

alias ag='ag --pager=$PAGER'

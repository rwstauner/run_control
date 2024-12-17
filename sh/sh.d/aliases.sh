# aliases (hooray!)

# interactive (confirmation prompt)
for i in rm mv cp;
  { alias $i="$i -iv"; }

# verbose
for i in rmdir mkdir rename;
  { alias $i="$i -v"; }

# let me use my aliases when delaying commands
for i in {g,}xargs watch sudo;
  { alias $i="$i "; }

# add readline support
for i in pacmd;
  { alias $i="rlwrap $i"; }

# Stay awake.
if which caffeinate &> /dev/null; then
  alias caffeinate='caffeinate '
  for i in abcde brew rsync; {
    alias $i="caffeinate -- $i";
  }
fi

alias abcde='env PAGER=cat caffeinate -- abcde'


# shortcuts for common args

alias caly='cal `date +%Y`'

alias diffpatch='diff -Npurd'
alias diffgit='\git diff --no-index'

for i in cw cww cws hl; {
  alias diffgit$i="\\git diff$i --no-index";
}

alias ftp='/usr/bin/ftp'; # kerberos ftp bothers me

# sometimes my finger can't let go of the shift key used to make the pipe
alias Wc=wc

# ls
alias ls='ls --color=auto --quoting-style=literal'
alias ll='ls -l'
alias lf='ll -aF'
alias lh='lf -h'
alias lft='lf --time-style=full-iso'

# Always use a pager.
for i in dict; {
  eval "$i"' () { command '"$i"' "$@" | $PAGER; }'
}

alias smenu='smenu -d -T'

alias weather='curl wttr.in'

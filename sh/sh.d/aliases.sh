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

# Stay awake.
if which caffeinate &> /dev/null; then
  alias caffeinate='caffeinate '
  for i in abcde brew; {
    alias $i="caffeinate $i";
  }
fi


# shortcuts for common args

alias caly='cal `date +%Y`'

alias diffpatch='diff -Npurd'
alias diffgit='\git diff --no-index'

for i in cw hl; {
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

# show child process hierarchy with indentation
alias ps='ps -H'

# Always use a pager.
for i in dict; {
  eval "$i"' () { command '"$i"' "$@" | $PAGER; }'
}

# I like ag's `--group` output but nogroup is more consistent with (git) grep
# and can easily be used as a vim quickfix buffer.
# Always look for ./.ignore even if searching specific directories.
alias ag='ag --path-to-ignore .ignore --pager=$PAGER --nogroup --color-match="1;31" --color-path=35 --color-line-number=32'
alias agq='ag --nofilename'

alias pdftk='drunw cartoncloud/pdftk'
alias pdfinfo='drunw flungo/poppler pdfinfo'

alias smenu='smenu -d -T'

# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
# .bashrc

## always do these things:

## environment variables for always [even when not in terminal]
  export BROWSER=firefox
  export FTP_PASSIVE=1; # used by Net::FTP, and maybe possibly hopefully some other things


## my personl path
  for dir in /opt/*/bin "$HOME/perl5/bin" "/monster/devel/linux" "$HOME/bin"; {
    if ! echo "$PATH" | grep -qE "(^|:)$dir(:|$)" && [[ -e "$dir" ]]; then
      export PATH="$dir:$PATH"
    fi;
  }

## only do these when in a terminal:

# this thing is so cluttered
if [ -n "$PS1" ] && [ "$TERM" != "dumb" ]; then

  function box_msg () {
#    if [[ $# -ne 1 ]]; then
      perl -MList::Util=max -e '@lines = @ARGV ? @ARGV : <STDIN>; chomp(@lines); $len = max map { length } @lines; print $b = "-" x ($len + 4) . "\n"; printf("| %-${len}s |\n",$_) for @lines; print $b;' "$@"
#    fi
#    local msg="$1" border="------------------------------------------------------------"
#    local len=$((${#msg}+4))
#    border="${border:0:$len}"
#    echo "$border"
#    echo "| $msg |"
#    echo "$border"
  }

## [terminal/login shell] environment variables
  # /usr/lib/locale/en_US.utf8
  export LANG=en_US.utf8
  export LANGUAGE=$LANG LOCALE=$LANG LC_ALL=$LANG LC_CTYPE=$LANG
  export PAGER=less LESS=FRX

  export JAVA_HOME=`ls -d $HOME/java/jdk* | head -n1`
  export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/
  export PYTHONSTARTUP=~/.python_startup
  export XML_CATALOG_FILES="$HOME/devel/xml/catalog /etc/xml/catalog"

## bash history
  #HISTIGNORE=lf
  export HISTCONTROL=ignoredups HISTFILESIZE=3000 HISTSIZE=3000
  #export HISTTIMEFORMAT='%H:%M:%S '

## time
  # use full path to use this variable (/usr/bin/time) otherwise the bash built-in takes over
  TIME="     \n time: %E %e:elapsed %U:user %S:system %P:cpu(u+s/e)"
  TIME="$TIME\n  mem: %K:avgtotal(data+stack+text) %M:max %t:avg %D:data+%p:stack+%X:text in Kbytes"
  TIME="$TIME\n m/io: %I:in+%O:out (%F:maj+%R:min)pagefaults +%W:swaps %c:switched %w:waits %r/%s:sockets i/o"
  export TIME

## Source global definitions
  for etc_bashrc in /etc/bash.bashrc /etc/bashrc; do
    if [ -f $etc_bashrc ]; then
      . $etc_bashrc
    fi
  done

## bash shell options
  shopt -s histreedit histverify extglob progcomp

## programmable completion
  if [ -f ~/.bash_completion ]; then
    . ~/.bash_completion
  fi

## aliases (hooray!)

  # interactive (confirmation prompt)
  for i in rm mv cp ; { alias $i="$i -iv" ; }

  # commands
  alias caly='cal `date +%Y`'
  #alias cd='echo -ne "\007"; cd'; # i've learned this by now
  alias diffpatch='diff -uprN'
  alias diffgit='git diff --no-index'
  alias diffgitcw='git diff --no-index --color-words=.'
  alias external_ip_address='dig +short myip.opendns.com @resolver1.opendns.com'
  alias ftp='/usr/bin/ftp' # kerberos ftp bothers me
  alias grep='env LC_ALL=POSIX grep --color=auto'
  alias Grep='grep'
  alias grepsvn='grep --exclude=\*.svn\* -R'
  alias zgrep='zgrep --color=auto'
  alias irb='nice -n 15 irb'
  alias ll='ls -l --color=auto'
  alias lf='ll -aF'
  alias lh='lf -h'
  alias lft='lf --time-style=full-iso'
  test -n "$LS_COLORS" || { eval `dircolors`;
    #export LS_COLORS="$LS_COLORS*.svg=00;35:*.xcf=00;35:*.html=00;33:*.css=00;33:*.js=00;33:";
    export LS_COLORS="$LS_COLORS*.svg=00;35:*.xcf=00;35:*.html=00;33:*.css=00;33:`for i in pl py rb lua tcl sh bash bsh; { echo -n "*.$i=00;32:"; }`";
  }
  alias pseo='ps -eo pid,ppid,pgid,user,%cpu,%mem,rss,state,tty,lstart,time,fname,command'
  alias psoe='pseo'
  alias psgrep='pseo | head -n1; pseo | grep'
  alias psvgrep='psgrep -v grep | grep'
  alias rename='rename -v'
  alias rmdir='rmdir -v'
  alias screencolor='woundedrc screencolor = "`grabc`"'
  #alias svndiff='svn diff --diff-cmd diff -x -iwBd'
  #alias svndiffu='svn diff --diff-cmd diff -x -iwBdu'
  #alias svnvimdiff="svn diff --diff-cmd arg_drop -x \"vimdiff -4-7 -R -s $HOME/.vim/svnvimdiff.vim\""
  alias vi='echo -e "use vim \007"; sleep 2; echo vim'
  alias vimXcat='ex -c w\ !\ cat -c :q'
  alias :sp='vim'

  # let me use my aliases when delaying commands
  for i in xargs watch sudo; { eval "alias $i='$i '"; }
  #alias sudo='echo " -- sudoing -- " 1>&2; sudo '

  function timed () { echo " :[timing from `date`]: " 1>&2; /usr/bin/time "$@"; }
  alias time=timed

## find psql w/o putting it in my path
  #pre_psql='env PAGER=less'
  for i in local/pgsql/ local/ '' ; {
    psql_bin="/usr/${i}bin/psql"; if [ -e "$psql_bin" ]; then alias psql="$psql_bin"; break; fi; }
  unset i pre_psql psql_bin

## commands more complex than aliases
  function astronomy_picture() { pushd /monster/media/images/astronomy/; wget "$*"; display `basename "$*"`; popd; }
  function browse_local_file() { local u="$1"; [[ ${u:0:1} == "/" ]] || u="$PWD/$u"; firefox "file://$u"; }
  if test -x $HOME/bin/extract_archive; then
    function extract_pushd(){ pushd "`extract_archive "$@"`"; }
  fi
  function eog { `which eog` "$@" &> /dev/null & }
  function math { if [[ $# -gt 0 ]]; then echo $'scale=2\n' "$*" | bc -l; else bc -l; fi; } #BC_ENV_ARGS=
  function mkdirpushd() { mkdir "$@"; pushd "$@"; }
  function my_ip(){ /sbin/ip addr show wlan0 | grep -oE '^\s*inet ([0-9.]+)' | awk '{print $2}'; }
  function rename_to_lowercase() {
    tmp=`mktemp -u $(dirname "$1")/$(basename "$1").XXXXXXXXXXX`;
    mv "$1" "$tmp"; mv "$tmp" "`echo "$1" | tr '[A-Z]' '[a-z]'`"; unset tmp;
  }
  #perl -C -E 'say"i \x{2764} ",($^X =~ m#([^/\\]+)$#)'

fi

for rc in ~/.bashrc.d/* $EXTRA_BASHRC; do
  [[ -f "$rc" ]] && [[ -r "$rc" ]] && source "$rc"
done

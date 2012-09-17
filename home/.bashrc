# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
# .bashrc

function source_rc_files () {
  local rc
  for rc in "$@"; do
    [[ -f "$rc" ]] && [[ -r "$rc" ]] && source "$rc"
  done
}

# Source global definitions
source_rc_files /etc/bash.bashrc /etc/bashrc

# different semantics than the typical pathmunge()
function add_to_path () {
  local after=0 dir
  if [[ "$1" == "--after" ]]; then after=1; shift; fi
  for dir in "$@"; do
    if [[ -d "$dir" ]] && ! echo "$PATH" | grep -qE "(^|:)$dir(:|$)"; then
      if [[ "$after" ]]; then PATH="$PATH:$dir"; else PATH="$dir:$PATH"; fi
    fi
  done
}

# add_to_path /opt/*/bin
add_to_path /opt/imagemagick/bin
add_to_path $HOME/devel/linux $HOME/bin

## only do these when in a terminal:

# this thing is so cluttered
if [ -n "$PS1" ] && [ "$TERM" != "dumb" ]; then

  function box_msg () {
#    if [[ $# -ne 1 ]]; then
      # TODO: wrap to $COLUMNS
      perl -MList::Util=max,min -e 'chomp(@lines = @ARGV ? @ARGV : <STDIN>); $len = max map { length } @lines; $len = min($ENV{COLUMNS}, $len) if $ENV{COLUMNS}; print $b = "-" x ($len + 4) . "\n"; printf("| %-${len}s |\n",$_) for @lines; print $b;' "$@"
#    fi
#    local msg="$1" border="------------------------------------------------------------"
#    local len=$((${#msg}+4))
#    border="${border:0:$len}"
#    echo "$border"
#    echo "| $msg |"
#    echo "$border"
  }

  # bash history
  shopt -s histappend histreedit histverify

  HISTCONTROL='ignoreboth:erasedups'

  # forget commands that are simple and generic (no args)
  HISTIGNORE='fc *:history:l[slfh]:cd:[bf]g:vim:pushd:popd'
  _hist_ignore_git=":amend:civ:status:st:s:adp:add -p:ls-files"
  HISTIGNORE="$HISTIGNORE${_hist_ignore_git//:/:git }"
  unset _hist_ignore_git

  HISTFILESIZE=3000 HISTSIZE=3000
  #export HISTTIMEFORMAT='%H:%M:%S '

## time
  # use full path to use this variable (/usr/bin/time) otherwise the bash built-in takes over
  TIME="     \n time: %E %e:elapsed %U:user %S:system %P:cpu(u+s/e)"
  TIME="$TIME\n  mem: %K:avgtotal(data+stack+text) %M:max %t:avg %D:data+%p:stack+%X:text in Kbytes"
  TIME="$TIME\n m/io: %I:in+%O:out (%F:maj+%R:min)pagefaults +%W:swaps %c:switched %w:waits %r/%s:sockets i/o"
  export TIME

  function timed () { echo " :[timing from `date`]: " 1>&2; /usr/bin/time "$@"; }
  #alias time=timed

## aliases (hooray!)

  # interactive (confirmation prompt)
  for i in rm mv cp ; { alias $i="$i -iv" ; }

  # commands
  alias caly='cal `date +%Y`'

  alias diffpatch='diff -uprN'
  alias diffgit='git diff --no-index'
  alias diffgitcw='git diff --no-index --color-words=.'

  alias external_ip_address='dig +short myip.opendns.com @resolver1.opendns.com'
  alias ftp='/usr/bin/ftp' # kerberos ftp bothers me

  alias ls='ls --color=auto'
  alias ll='ls -l'
  alias lf='ll -aF'
  alias lh='lf -h'
  alias lft='lf --time-style=full-iso'
  if ! [[ -n "$LS_COLORS" ]]; then
    if which dircolors &> /dev/null; then
      eval `dircolors`
      if [[ -r ~/.dircolors ]]; then
        _def_ls_colors="$LS_COLORS"
        eval `dircolors ~/.dircolors`
        LS_COLORS="${_def_ls_colors}$LS_COLORS"
        unset _def_ls_colors
      fi
    fi
  fi

  function psgrep () {
    ps -eo pid,ppid,pgid,user,%cpu,%mem,rss,state,tty,lstart,time,fname,command | \
      { read; echo "$REPLY"; cat | grep "$@"; };
  }

  alias rename='rename -v'
  alias rmdir='rmdir -v'

  if which notify-send &> /dev/null; then
    # copied from ubu 12.04 default .bashrc:
    # Add an "alert" alias for long running commands.  Use like so:
    #   sleep 10; alert
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
  fi

  # let me use my aliases when delaying commands
  for i in xargs watch sudo; { eval "alias $i='$i '"; }

  # add readline support
  for i in pacmd; {
    which $i &> /dev/null && alias $i="rlwrap $i";
  }

## commands more complex than aliases
  function astronomy_picture() { pushd /monster/media/images/astronomy/; wget "$*"; display `basename "$*"`; popd; }
  function browse_local_file() { local u="$1"; [[ ${u:0:1} == "/" ]] || u="$PWD/$u"; firefox "file://$u"; }

  if test -x $HOME/bin/extract_archive; then
    function extract_pushd(){ pushd "`extract_archive "$@"`"; }
  fi

  function math { if [[ $# -gt 0 ]]; then echo $'scale=2\n' "$*" | bc -l; else bc -l; fi; } #BC_ENV_ARGS=
  function mkdirpushd() { mkdir "$@"; pushd "$@"; }
  function my_ip(){ /sbin/ip addr show wlan0 | grep -oE '^\s*inet ([0-9.]+)' | awk '{print $2}'; }
  function rename_to_lowercase() {
    tmp=`mktemp -u $(dirname "$1")/$(basename "$1").XXXXXXXXXXX`;
    mv "$1" "$tmp"; mv "$tmp" "`echo "$1" | tr '[A-Z]' '[a-z]'`"; unset tmp;
  }
  #perl -C -E 'say"i \x{2764} ",($^X =~ m#([^/\\]+)$#)'

  function scan_pdf () {
    scan_dir=`mktemp -d /tmp/scan.XXXXXX`
    (cd "$scan_dir"; hp-scan --grey --size=letter --adf -r 200)
    mv  "$scan_dir/hpscan001.pdf" "$1"
  }

  # don't barf all over my terminal and make me 'reset'
  for cmd in evince eog; do
    eval "function $cmd () { echo 'redirecting $cmd...'; command $cmd \"\$@\" &> /dev/null & }"
  done

fi

source_rc_files ~/.bashrc.d/* $EXTRA_BASHRC

unset -f add_to_path source_rc_files

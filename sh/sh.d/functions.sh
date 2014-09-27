# shell utilities

mkdirpushd () {
  mkdir "$@"
  pushd "$@"
}

from () {
  local dir="$1"; shift
  # Use subshell in case the process dies.
  (cd "$dir" || return; "$@")
}

# print the full path to a relative file
full-path () {
  local f="$1"
  [[ ${f:0:1} == "/" ]] || f="$PWD/$f"
  echo "$f"
}

# rename_to_lowercase () {
#   tmp=`mktemp -u "$1".XXXXXXXXXXX`;
#   mv "$1" "$tmp"; mv "$tmp" "`echo "$1" | tr '[A-Z]' '[a-z]'`"; unset tmp;
# }

# show headers and grep the rest
headgrep () {
  local head="${1#-n}"; shift
  local i=0;
  for ((i=0; i<$head; ++i)); do
    # should this be stderr?
    read -r; echo "$REPLY";
  done
  grep "$@";
}

psgrep () {
  command ps -eo pid,ppid,pgid,user,%cpu,%mem,rss,state,tty,lstart,time,fname,command | \
    headgrep -n1 "$@";
}

# calculator
# can put pre-ARGV in this var (useful to load other files or specify options)
export BC_ENV_ARGS="-l"
# if given args pipe them to the command, otherwise give a prompt
math () {
  if [[ $# -gt 0 ]]; then
    local scale='scale=2;';
    if [[ "x$1" == "x-s" ]]; then
      scale="scale=$2;";
      shift 2;
    fi
    echo "$scale$*" | bc
  else
    bc;
  fi;
}

#if [[ -x $HOME/bin/extract_archive ]]; then
  extract_pushd (){
    local dir="`extract_archive "$@"`";
    if [[ -n "$dir" ]]; then
      pushd "$dir";
    else
      echo "can't pushd to nothing" 1>&2;
    fi;
  }
#fi

# time
  # use full path to use this variable (/usr/bin/time) otherwise the bash built-in takes over
  TIME="     \n time: %E %e:elapsed %U:user %S:system %P:cpu(u+s/e)"
  TIME="$TIME\n  mem: %K:avgtotal(data+stack+text) %M:max %t:avg %D:data+%p:stack+%X:text in Kbytes"
  TIME="$TIME\n m/io: %I:in+%O:out (%F:maj+%R:min)pagefaults +%W:swaps %c:switched %w:waits %r/%s:sockets i/o"
  export TIME

  timed () {
    echo " :[timing from `date`]: " 1>&2
    /usr/bin/time "$@"
  }

  #alias time=timed
  #alias time=/usr/bin/time; # avoid bash built-in to enable $TIME format

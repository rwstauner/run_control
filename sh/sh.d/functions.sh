# shell utilities

mkdirpushd () {
  mkdir "$@"
  pushd "$@"
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

# draw a box around a message
  box_msg () {
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

no_sound () {
  NO_SOUND=1 "$@"
}

notify_result () {
  local rv=$?
  local dir=`pwd`

  if [[ $rv -eq 0 ]]; then
    local pf=Passed
    local sound="$HOME/data/audio/angry_birds/angry_birds-cheer_1.ogg"
    local player=ogg123
  else
    local pf=Failed
    local sound="$HOME/data/audio/Super_Mario_Bros_Game_Over_8b6975.mp3"
    local player=mpg123
  fi

  local img="$HOME/data/images/icons/tux.png"
  if [[ "$1" == "-i" ]]; then
    img="$2"; shift 2;
  fi

  if [[ -z "$NO_SOUND" ]] && [[ -e "$sound" ]]; then
    # play sound async without showing anything on screen
    { $player $sound & disown; } &> /dev/null
  fi

  # show pop-up notification
  /usr/bin/notify-send -i "$img" "Tests: $pf" "$dir"

  # preserve exit status
  return $rv
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

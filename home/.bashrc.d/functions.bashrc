# shell utilities

function mkdirpushd () { mkdir "$@"; pushd "$@"; }

# print the full path to a relative file
function full_path () { local f="$1"; [[ ${f:0:1} == "/" ]] || f="$PWD/$f"; echo "$f"; }

# function rename_to_lowercase() {
#   tmp=`mktemp -u "$1".XXXXXXXXXXX`;
#   mv "$1" "$tmp"; mv "$tmp" "`echo "$1" | tr '[A-Z]' '[a-z]'`"; unset tmp;
# }

# draw a box around a message
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

# show headers and grep the rest
function headgrep () {
  local head="${1#-n}"; shift
  local i=0;
  for ((i=0; i<$head; ++i)); do
    # should this be stderr?
    read -r; echo "$REPLY";
  done
  grep "$@";
}

function psgrep () {
  command ps -eo pid,ppid,pgid,user,%cpu,%mem,rss,state,tty,lstart,time,fname,command | \
    headgrep -n1 "$@";
}

# calculator
# can put pre-ARGV in this var (useful to load other files or specify options)
export BC_ENV_ARGS="-l"
# if given args pipe them to the command, otherwise give a prompt
function math () {
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
  function extract_pushd(){
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

  function timed () { echo " :[timing from `date`]: " 1>&2; /usr/bin/time "$@"; }
  #alias time=timed
  #alias time=/usr/bin/time; # avoid bash built-in to enable $TIME format

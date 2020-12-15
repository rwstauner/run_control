# shell utilities

mkdirpushd () {
  mkdir "$@"
  pushd "$@"
}

from () {
  local dir="$1"; shift
  # Use subshell in case the process dies.
  (cd "$dir" || return; eval "$@")
}

# print the full path to a relative file
full-path () {
  local f="$1"
  [[ ${f:0:1} == "/" ]] || f="$PWD/$f"
  echo "$f"
}

gethostbyname () {
  perl -MSocket -e 'printf "%s\n", inet_ntoa(scalar gethostbyname($ARGV[0]))' "$@"
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

keep-trying () {
  local i=0
  while ! "$@"; do
    echo " ⚠ $i"
    i=$((i+1))
  done
  echo " ✓ $i"
}

psgrep () {
  command ps -eo pid,ppid,pgid,user,%cpu,%mem,rss,state,tty,lstart,time,fname,command | \
    headgrep -n1 "$@";
}

show-args () {
  # Set SHOW_ARGS_SPEC=%s to display regularly (%s vs %q).
  local arg i=0
  for arg in "$@"; do
    printf "%3d: «${SHOW_ARGS_SPEC:-%q}»\n" $((++i)) "$arg"
  done
}

# calculator
# can put pre-ARGV in this var (useful to load other files or specify options)
export BC_ENV_ARGS="-l"
# if given args pipe them to the command, otherwise give a prompt
function math {
  if [[ $# -gt 0 ]]; then
    local scale='scale=5;';
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

function unzip_single_file {
  zip="$1"
  if [[ `unzip -qql "$zip" | wc -l` -ne 1 ]]; then
    echo "not a single file" >&2
    return 1
  fi
  unzip -p "$zip" > "${zip%.zip}.content"
}

httpd () {
  # python3 -m http.server
  python2 -m SimpleHTTPServer "$@"
}

terraform () {
  if [[ -s terragrunt.hcl ]]; then
    command terragrunt "$@"
  else
    command terraform "$@"
  fi
}

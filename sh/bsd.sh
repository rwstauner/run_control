# test "`uname -s`" = "Darwin"

# BSD ls doesn't do --color=auto but respects env var.
unalias ls
export CLICOLOR=1

# no -v
unalias rmdir

# no fname
psgrep () {
  command ps -eo pid,ppid,pgid,user,%cpu,%mem,rss,state,tty,lstart,time,command | headgrep -n1 "$@"
}

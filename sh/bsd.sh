# test "`uname -s`" = "Darwin"

# BSD ls doesn't do --color=auto but respects env var.
unalias ls
export CLICOLOR=1

# no -H
unalias ps

# no -v
unalias rmdir

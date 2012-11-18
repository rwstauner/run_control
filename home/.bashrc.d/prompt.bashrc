## unfortunately complicated prompt

#if [[ -z "$GNU_SCREEN_TERM" ]] && [[ -z "$TMUX" ]]; then
  #PS1=' \[\033[0000m\033[31m\]\u@\[\033[01m\]\h\[\033[00;31m\]#\l \w [\j \t $?] \s \V\[\033[0m\] \n\[\033[31m\]\$\[\033[0m\] '
  #PS1='\[ \033[0000m\033[31m\u@\033[01m\h\033[00;31m#\l \w [\j \t $?] \s \V\033[00m \]\n\$ '
#else
  # the first set of escapes are for screen/bash: \e[0000m normalizes color and rounds the length of invisible chars to 8
  # \ek\e\\ is for dynamic screen AKA's
  #PS1=' \[\033[0000m\033k\033\134\033[36m\]\u\[\033[37m\]@\[\033[36m\033[1m\]\h\[\033[0m\033[37m\]#\[\033[36m\]\l \[\033[33m\]\w\[\033[0m\] \[\033[34m\][\[\033[36m\]\j\[\033[34m\] \t \[\033[36m\]$?\[\033[34m\]] \[\033[35m\]\s \V\[\033[0m\] \n\[\033[0007m\]\$\[\033[0000m\] '
  #PS1=' \[\033[0000m\033k\033\134\033[36m\]\u\[\033[37m\]@\[\033[36;01m\]\h\[\033[00;37m\]#\[\033[36m\]\l \[\033[33m\]\w\[\033[00m\] \[\033[34m\][\[\033[36m\]\j\[\033[34m\] \t \[\033[36m\]$?\[\033[34m\]] \[\033[35m\]\s \V\[\033[00m\] \n\[\033[0007m\]\$\[\033[0000m\] '

  # vary main prompt color by hostname if we're at work (judged by having more than 1 dot in hostname)
  PS1_MAIN_COLOR=`perl -e '$h=$ARGV[0]; print 30 + (($h =~ tr/.//) >= 2 ? (ord(substr($ARGV[0], 0, 1)) % 6) + 1 : 6)' $(hostname)`
  PS1='\[ \033[0000m\033[${PS1_MAIN_COLOR}m\u\033[37m@\033[$PS1_MAIN_COLOR;01m\h\033[00;37m:\033[00;${PS1_MAIN_COLOR}m\w\033[37m #\033[33m\l \033[34m[\033[33m&\033[36m\j\033[34m \t \033[36m$?\033[33m?\033[34m] \033[35m\s \V\033[32m/\033[33m${MULTIPLEXER}\033[34m perl/$PERLBREW_PERL${rvm_version:+ \033[35m${GEM_HOME##*/}}\033[00m \]\n\$ '
#fi

# use "set -x" to show the commands about to be executed (prefixed by PS4)
PS4="## "

# https://twitter.com/#!/wilshipley/status/93955570893205504
# And the same for bash: PS1="\e0;\u@\H: \w\a$PS1" Preferably in your ~/.profile

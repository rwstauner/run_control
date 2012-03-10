# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
# .bashrc

## always do these things:

## environment variables for always [even when not in terminal]
  export BROWSER=firefox
  export FTP_PASSIVE=1; # used by Net::FTP, and maybe possibly hopefully some other things

## editor of choice (Vim!)
  EDITOR=/usr/bin/vim
  [ -e '/usr/local/bin/vim' ] && EDITOR=/usr/local/bin/vim
  FCEDIT=$EDITOR
  VISUAL=$EDITOR
  export EDITOR FCEDIT VISUAL

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

## local perl mods
  export NOPASTE_NICK=rwstauner
  export NOPASTE_SERVICES='Gist Shadowcat Pastie Snitch'
  alias buzzword='perl -MAcme::MetaSyntactic=buzzwords -le "print metaname"'
  alias gmstamp='perl -e "use Time::Stamp gmstamp => {@ARGV}; print gmstamp, qq[\n]"'
  # LWP 6.00 breaks CPAN::Reporter (when using Metabase Transport)
  # cert purchased on 2011/03/15
  #alias cpan='env PERL_LWP_SSL_VERIFY_HOSTNAME=0 cpan'

  # get the PERL5LIB, but don't set the install paths (cpanm handles that)
  # usage of local::lib is currently undecided thanks to perlbrew...
  #eval $(perl -Mlocal::lib | grep PERL5LIB)

  #export PERL_UNICODE=AS
  minicpan=$HOME/perl5/cpan/mini
  #export PERL_CPANM_OPT="--save-dists $minicpan --mirror $minicpan --mirror http://cpan.ezarticleinformation.com/ --mirror http://search.cpan.org/CPAN/"
  export PERL_CPANM_OPT="--save-dists $minicpan --mirror http://localhost:4999/CPAN/ --mirror http://cpan.ezarticleinformation.com/ --mirror http://search.cpan.org/CPAN/"
  unset minicpan

  perlbrewrc="$HOME/perl5/perlbrew/etc/bashrc"
  [[ -r "$perlbrewrc" ]] && source "$perlbrewrc"

  # after perlbrew
  which setup-bash-complete &> /dev/null && . setup-bash-complete

  # dzil aliases
  if which dzil &> /dev/null; then
    function dzil () {
      local dzil="`which dzil`"
      case "$1" in
        installm)
          local dest=""
          if grep -F '@AutoLookout' dist.ini; then dest="$HOME/perl5-autolookout"; fi
          $dzil install --install-command="cpanm -v -i . ${dest:+-l }$dest";;
        *)        $dzil "$@";;
      esac
    }
  fi

  alias perl1='perl -CSDLA -Mcharnames=:full -MData::Printer -MData::Dumper -MYAML::Any -MClass::Autouse=:superloader -E "sub D(\$){ print Dumper(shift) } sub Y(\$){ print Dump(shift) } sub P(\$) { &p(shift) }"'
  alias perldoc='env LANG=en_US perldoc'
# alias podspelltest='perl -MTest::More -MTest::Spelling -e "set_spell_cmd(q[aspell list]); all_pod_files_spelling_ok(@ARGV)"'
  alias podspelltest='perl -MTest::More -MTest::Spelling -MPod::Wordlist::hanekomu -e "all_pod_files_spelling_ok(@ARGV)"'
  #alias podserver='{ sleep 2; $BROWSER http://localhost:8088/@frames; } & pgrep pod_server || { pod_server -s left -f ${1:-perl}; sleep 1; };'
  alias podserver='{ sleep 2; $BROWSER http://localhost:4998; } & plackup -p 4998 -e "my \$app = require Pod::POM::Web::PSGI"'
  function podhtmlview() { local u="$1"; [[ ${u:0:1} == "/" ]] || u="$PWD/$u"; firefox "http://localhost/podhtml.cgi?pod=$u"; }
  function mversion() { if [ $# -eq 0 ]; then m=${PWD##*/}; else m="$1"; fi; `which mversion` ${m//-/::}; }

  function grep_pm() { zgrep --color=auto "$@" ~/perl5/cpan/mini/modules/02packages.details.txt.gz; }
  function cover_tests () {
    cover -delete; #rm -rf cover_db/;
    PERL5OPT=-MDevel::Cover perl -Ilib "$@" 2> /dev/null;
    cover;
  }
  function prove_coverage () {
    cover -delete;
    HARNESS_PERL_SWITCHES="-I$HOME/perl5/local-lib-5.14-devel-cover/lib/perl5 -MDevel::Cover" prove --color "$@" 2>&1 | grep -v "Devel::Cover: Can't open";
    cover;
  }

  alias alternate='perl -ne "print( qq/\033[/ . ( \$. % 2 ? q/33/ : q/36/ ). q/m/ . \$_ . qq/\033[0m/ );"'
  #alias base64='perl -MMIME::Base64 -0777 -ne "print encode_base64(\$_)"'

  function perltidydiff () {   perltidy < "$1" | git diffcw --no-index "$1" - | perl -pe 's/\033\[3(\d)m/\033[4$1m/g'; }
  # get the pm file rather than the pod file (if they're different)
  function vim_pm () {
    pm=`module_info "$@" | awk '/^File:/ { print $2 }'`;
    [[ -n "$pm" ]] || pm=`perldoc -l "$@"`
    pm="${pm/.pod/.pm}"
    if [[ -e "$pm" ]]; then
      vim "$pm"
    else
      vim -c 'set ft=perl' -c "norm iuse $1;" -c 'norm B\f' -c 'bunload! 1';
    fi
  }

## always use a terminal mutliplexer
  # NOTE: tmux is particular about $TERM ("xterm" outside, "screen" inside)
  [[ -z "$MULTIPLEXER" ]] && [[ -n "$TMUX" ]] && export MULTIPLEXER=tmux
  #if [[ -n "$TMUX" ]]; then
    term_plain=${TERM%%-*color}
      # do 256 if supported...
      desired_term=${TERM%%-*color}-256color
      terminfo_entry="terminfo/${desired_term:0:1}/$desired_term"
      if [[ -e "/lib/$terminfo_entry" ]]; then
        TERM="$desired_term"
      elif [[ -e "/usr/share/$terminfo_entry" ]]; then
        TERM="$desired_term"
      else
        box_msg "terminfo for $desired_term not found!"
        # just leave it the way it was; TERM=$term_plain
      fi
      unset desired_term terminfo_entry term_plain
  #else
    #if [[ "$TERM" == 'screen' ]]; then
      #export TERM=xterm
      #export GNU_SCREEN_TERM=xterm
    if [[ -z "$TMUX" && -z "$GNU_SCREEN" ]]; then
      # remind me that i'm not using a terminal multiplexer
      if which screen &> /dev/null; then
        echo '  screen:'
        screen -ls
      fi
      echo '  tmux:'
      tmux list-sessions
      echo
    fi
  #fi

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

## unfortunately complicated prompt
  #if [[ -z "$GNU_SCREEN_TERM" ]] && [[ -z "$TMUX" ]]; then
    # TODO: rotate color depending on (hostname | md5sum | cut -c1) ?
    #PS1=' \[\033[0000m\033[31m\]\u@\[\033[01m\]\h\[\033[00;31m\]#\l \w [\j \t $?] \s \V\[\033[0m\] \n\[\033[31m\]\$\[\033[0m\] '
    #PS1='\[ \033[0000m\033[31m\u@\033[01m\h\033[00;31m#\l \w [\j \t $?] \s \V\033[00m \]\n\$ '
  #else
    # the first set of escapes are for screen/bash: \e[0000m normalizes color and rounds the length of invisible chars to 8
    # \ek\e\\ is for dynamic screen AKA's
    #PS1=' \[\033[0000m\033k\033\134\033[36m\]\u\[\033[37m\]@\[\033[36m\033[1m\]\h\[\033[0m\033[37m\]#\[\033[36m\]\l \[\033[33m\]\w\[\033[0m\] \[\033[34m\][\[\033[36m\]\j\[\033[34m\] \t \[\033[36m\]$?\[\033[34m\]] \[\033[35m\]\s \V\[\033[0m\] \n\[\033[0007m\]\$\[\033[0000m\] '
    #PS1=' \[\033[0000m\033k\033\134\033[36m\]\u\[\033[37m\]@\[\033[36;01m\]\h\[\033[00;37m\]#\[\033[36m\]\l \[\033[33m\]\w\[\033[00m\] \[\033[34m\][\[\033[36m\]\j\[\033[34m\] \t \[\033[36m\]$?\[\033[34m\]] \[\033[35m\]\s \V\[\033[00m\] \n\[\033[0007m\]\$\[\033[0000m\] '

    # vary main prompt color by hostname if we're at work (judged by having more than 1 dot in hostname)
    hostcolor=`perl -e '$h=$ARGV[0]; print (($h =~ tr/.//) >= 2 ? (ord(substr($ARGV[0], 0, 1)) % 6) + 1 : 6)' $(hostname)`
    PS1='\[ \033[0000m\033[3'$hostcolor'm\u\033[37m@\033[3'$hostcolor';01m\h\033[00;37m:\033[00;3'$hostcolor'm\w\033[37m #\033[33m\l \033[34m[\033[33m&\033[36m\j\033[34m \t \033[36m$?\033[33m?\033[34m] \033[35m\s \V\033[32m/\033[33m'$MULTIPLEXER'\033[34m $PERLBREW_PERL\033[00m \]\n\$ '
    unset hostcolor
  #fi

  # use "set -x" to show the commands about to be executed (prefixed by PS4)
  PS4="## "

  # https://twitter.com/#!/wilshipley/status/93955570893205504
  # And the same for bash: PS1="\e0;\u@\H: \w\a$PS1" Preferably in your ~/.profile

## ratpoison
  if ps -ef | grep -v grep | grep -q /usr/local/bin/ratpoison; then
    alias focus_ratpoison='ratpoison -d :0.0 -c focus; chvt 7; logout'
  fi

fi

for rc in ~/.bashrc.d/*; do
  [[ -f "$rc" ]] && [[ -r "$rc" ]] && source "$rc"
done

## unfortunately complicated prompt

# Initialize to empty so we can append for readability.
PS1=''

_prompt_ () {
  local add='' autoreset=false
  while [[ $# -gt 0 ]]; do

    # Simplify escape sequences.
    case "$1" in
      -b) add='\033[01m';                ;;
      -c) add='\033['"$2"'m'; shift;     ;;
      -m) add='\033[${PS1_MAIN_COLOR}m'; autoreset=true;;
      -r) add='\033[00m';;
      *)  add="$1";;
    esac

    PS1="$PS1""$add"

    shift
  done
  $autoreset && PS1="$PS1"'\033[00m'
}

# if something

  # For screen/bash: \e[0000m normalizes color and rounds the length of invisible chars to 8.
  # The \ek\e\\ is for dynamic screen AKA's.
  # \[\033[0000m\033k\033\134\]

  # Vary main prompt color by hostname (use var to allow customizing).
  PS1_MAIN_COLOR=`perl -e '$h=$ARGV[0]; print 30 + (($h =~ tr/.//) >= 2 ? (ord(substr($ARGV[0], 0, 1)) % 6) + 1 : 6)' $(hostname)`

  # Embed variables in single quotes to delay interpolation until
  # display time (so they update dynamically).

  # Tell readline to ignore contents (between \[ and \])..
  _prompt_ '\[' -r

  # Put temporary note in a line above the prompt.
  _prompt_   -c '44;01' '${PS1_NOTE}${PS1_NOTE:+\n}'

  # Put an uncommon character at the front to identify start of prompt.
  # ∷ ⎇  ⬕ 🚀 😎 🔥 🔚 💥 👻 🐧 🐾 🏁 🎃 🍪 🌵 🌉 🌀 🃟
  # 4DFE ䷾ HEXAGRAM FOR AFTER COMPLETION
  _prompt_   -r -c 01 '💥 '

  # Some information about the environment.

  _prompt_   -c '01;32' 'env' -r ': '

  # Shell name and version.
  _prompt_   -c 35 '\s \V'
  _prompt_   -c 32 '/'

  # Terminal multiplexer (tmux or screen).
  _prompt_   -c 33 '${MULTIPLEXER}'

  # Perl (perlbrew)
  _prompt_   -c 34 '${PERLBREW_PERL:+ perl/}${PERLBREW_PERL#perl-}'

  # Python (virtualenv)
  _prompt_   -c 33 '${VIRTUAL_ENV:+ py/}${VIRTUAL_ENV##*/}'

  # Ruby (rvm)
  _prompt_   -c 35 '${rvm_version:+ ${GEM_HOME##*/}}'


  # Separate lines to keep prompt width short for smaller screens.
  _prompt_     '\n '


  # Typical prompt info (user@host:pwd)
  _prompt_   -m    '\u'
  _prompt_   -c 37  '@'
  _prompt_   -m -b '\h'
  _prompt_   -c 37  ':'
  _prompt_   -m    '\w'
  _prompt_   -c 37 ' #'
  _prompt_   -c 33 '\l'

  # Extra info
  _prompt_   -c 34 ' ['

  # Number of jobs in the background.
  _prompt_   -c 33 '&' -c 36 '\j'

  # Time (%H:%M:%S)
  _prompt_   -c 34 ' \t '

  # Exit status of last command.
  _prompt_   -c 36 '$?' -c 33 '?'

  _prompt_   -c 34 ']'

  _prompt_ -r '\]'

  # Put prompt character on a line by itself.
  _prompt_ '\n\$ '

#fi

# use "set -x" to show the commands about to be executed (prefixed by PS4)
PS4="## "

# https://twitter.com/#!/wilshipley/status/93955570893205504
# And the same for bash: PS1="\e0;\u@\H: \w\a$PS1" Preferably in your ~/.profile

unset -f _prompt_

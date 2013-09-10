## unfortunately complicated prompt

# Initialize to empty so we can append for readability.
PS1=''

function _prompt_ () {
  while [[ $# -gt 0 ]]; do
    # TODO: Simplify escape sequences.
    PS1="$PS1""$1"
    shift
  done
}

# if something

  # For screen/bash: \e[0000m normalizes color and rounds the length of invisible chars to 8.
  # The \ek\e\\ is for dynamic screen AKA's.
  # \[\033[0000m\033k\033\134\]

  # Vary main prompt color by hostname (use var to allow customizing).
  PS1_MAIN_COLOR=`perl -e '$h=$ARGV[0]; print 30 + (($h =~ tr/.//) >= 2 ? (ord(substr($ARGV[0], 0, 1)) % 6) + 1 : 6)' $(hostname)`

  # Tell readline to ignore contents (between \[ and \])..
  _prompt_ '\['

  # Put temporary note in a line above the prompt.
  _prompt_   '\033[00;44;01m'
  _prompt_     '${PS1_NOTE}'
  _prompt_     '${PS1_NOTE:+\n}'
  _prompt_   '\033[00;01m'

  # Put an uncommon character at the front to identify start of prompt.
  # ∷ ⎇  ⬕ 🚀 😎 🔥 🔚 💥 👻 🐧 🐾 🏁 🎃 🍪 🌵 🌉 🌀 🃟
  # 4DFE ䷾ HEXAGRAM FOR AFTER COMPLETION
  _prompt_     '💥 '

  _prompt_   '\033[00m'
  _prompt_   '\033[01;32m'

  # Some information about ENV.
  _prompt_     'env'
  _prompt_   '\033[00m'
  _prompt_     ': '
  _prompt_   '\033[35m'

  # Shell name and version.
  _prompt_     '\s \V'
  _prompt_   '\033[32m'
  _prompt_     '/'

  # Terminal multiplexer (tmux or screen).
  _prompt_   '\033[33m'
  _prompt_     '${MULTIPLEXER}'

  # Perl (perlbrew)
  _prompt_   '\033[34m'
  _prompt_     ' perl/$PERLBREW_PERL'

  # Python (virtualenv)
  _prompt_     '${VIRTUAL_ENV:+ \033[33mpy/}${VIRTUAL_ENV##*/}'
  _prompt_   '\033[00m'

  # Ruby (rvm)
  _prompt_     '${rvm_version:+ \033[35m${GEM_HOME##*/}}'
  _prompt_   '\033[00m'


  # Separate lines to keep prompt width short for smaller screens.
  _prompt_     '\n '


  # Typical prompt info (user@host:pwd)
  _prompt_   '\033[00m\033[${PS1_MAIN_COLOR}m'
  _prompt_     '\u'
  _prompt_   '\033[37m'
  _prompt_     '@'
  _prompt_   '\033[${PS1_MAIN_COLOR};01m'
  _prompt_     '\h'
  _prompt_   '\033[00;37m'
  _prompt_     ':'
  _prompt_   '\033[00;${PS1_MAIN_COLOR}m'
  _prompt_     '\w'
  _prompt_   '\033[37m'
  _prompt_     ' #'
  _prompt_   '\033[33m'
  _prompt_     '\l '

  # Extra info
  _prompt_   '\033[34m'
  _prompt_     '['

  # Number of jobs in the background.
  _prompt_     '\033[33m'
  _prompt_       '&'
  _prompt_     '\033[36m'
  _prompt_       '\j'

  # Time (%H:%M:%S)
  _prompt_     '\033[34m'
  _prompt_       ' \t '
  _prompt_     '\033[36m'

  # Exit status of last command.
  _prompt_       '$?'
  _prompt_     '\033[33m'
  _prompt_       '?'

  _prompt_     '\033[34m'
  _prompt_     ']'

  _prompt_   '\033[00m'
  _prompt_ '\]'

  # Put prompt character on a line by itself.
  _prompt_ '\n\$ '

#fi

# use "set -x" to show the commands about to be executed (prefixed by PS4)
PS4="## "

# https://twitter.com/#!/wilshipley/status/93955570893205504
# And the same for bash: PS1="\e0;\u@\H: \w\a$PS1" Preferably in your ~/.profile

unset -f _prompt_

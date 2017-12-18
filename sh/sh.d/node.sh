add_to_path ~/usr/node/bin

export NODE_REPL_HISTORY_FILE=$HOME/node/.hist
export N_PREFIX=$HOME/node/n

eslint () {
  local changed
  case "$*" in
    last-changed|changed)
      git "$1" | awk '/\.js$/ { printf "\0%s", $0 }' | IFS=$'\0' read -A changed
      set -- "${changed[@]}"
      shift; # The first element is empty.
      ;;
  esac
  npm-bin eslint "$@"
}

for i in \
  grunt \
  karma \
  stylelint \
  yarn \
; {
  alias $i="npm-bin $i"
}

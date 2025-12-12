# ZSH will call this when cd'ing.
chpwd () {
  # OSC7
  printf '\033]7;file://%s%s\033\\' "$HOST" "$PWD"
}

# Announce what dir the shell starts from.
chpwd

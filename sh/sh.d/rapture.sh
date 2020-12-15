# https://github.com/daveadams/go-rapture
rapture () {
  unset -f rapture
  eval "$( command rapture shell-init )"
  rapture "$@"
}

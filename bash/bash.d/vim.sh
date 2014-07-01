# <3 zsh's =name arguments.
vim_which () {
  vim `which "$1"`
}
complete -c vim_which

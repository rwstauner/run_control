# Source this explicitly in ~/.zshrc.local

test -f /etc/arch-release || return

yay () {
  sudo -v
  caffeinate yay --answerclean N --answerdiff N --noconfirm "$@"
}

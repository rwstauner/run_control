#!/bin/zsh

# Compare to loader.

# Get sh-compatible stuff first.
source ${0:h:h}/sh/mini.sh

# Just for fun.
include_pattern () {
  local pattern="$1"; shift
  for rc in "$@"; do
    include ${pattern/\%s/$rc}
  done
}

zshd_files=(
  aliases
  autoload
  completion
  functions
  history
  options
  vim-emacs
  zle-special-widgets
  zle
)

# Initial zsh settings.
include "$dir/zsh/pre-load.zsh"

# Load `zsh.d/*`.
include_pattern "$dir/zsh/zsh.d/%s.zsh" "${zshd_files[@]}"

# Load prompt (normally loaded by ohmyzsh which we've omitted).
include $dir/zsh/prompt.zsh

# Always check for a local file.
lazy_source '~/.zshrc.local'

_activate_rvm () {
  alias rvm &> /dev/null && unalias rvm

  # rvm appends this to .bashrc:
  PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

  # rvm appends this to .bash_profile:
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
}

# lazy load
alias rvm='_activate_rvm; rvm'

# Turn it on so we have gem-installed utils in $PATH.
[[ -z "$RUBY_VERSION" ]] && rvm use default &> /dev/null

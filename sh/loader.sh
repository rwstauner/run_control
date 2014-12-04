umask 022

source_rc_files () {
  local rc
  for rc in "$@"; do
    [[ -f "$rc" ]] && [[ -r "$rc" ]] && source "$rc"
  done
}

# different semantics than the typical pathmunge()
add_to_path () {
  local after=false dir
  if [[ "$1" == "--after" ]]; then after=true; shift; fi
  for dir in "$@"; do
    if [[ -d "$dir" ]]; then
      if $after; then
        PATH="$PATH:"
        PATH="${PATH//$dir:/}$dir";
      else
        PATH=":$PATH"
        PATH="$dir${PATH//:$dir/}";
      fi
    fi
  done
}

shrc_dir=$HOME/run_control/sh

# Setup terminal first.
source_rc_files $shrc_dir/term.sh


# Build $PATH.
# Instead of adding /opt/*/bin to $PATH
# consider symlinking those scripts into ~/usr/bin
# to keep the $PATH shorter so less searching is required.

# Locally compiled (without sudo).
add_to_path $HOME/usr/bin

# Homebrew.
add_to_path $HOME/homebrew/bin
# Get (unprefixed) GNU utils to override BSD utils.
add_to_path $HOME/homebrew/opt/coreutils/libexec/gnubin

# Personal scripts.
add_to_path $HOME/bin


# Get everything else.
source_rc_files $shrc_dir/sh.d/*.sh ~/.shrc.local $EXTRA_SHRC

unset shrc_dir

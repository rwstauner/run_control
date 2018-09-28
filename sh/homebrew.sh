# Keep this in separate file so it can be loaded in normal sh setup
# or after installing homebrew on demand.

# Get brew exec.
add_to_path $HOME/homebrew/{bin,sbin}

# Get (unprefixed) GNU utils to override BSD utils.
add_to_path $HOME/homebrew/opt/coreutils/libexec/gnubin

function man-nognu () {
  gnuman="$HOME/homebrew/opt/coreutils/libexec/gnuman:$HOME/homebrew/share/man"
  MANPATH="${MANPATH/$gnuman:/}" man "$@"
}

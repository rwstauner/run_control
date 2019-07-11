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

with-brew-env () {
  PKG_CONFIG_PATH="$PKG_CONFIG_PATH $HOME/homebrew/opt/libxml2/lib/pkgconfig" \
    LDFLAGS="$LDFLAGS -L$HOME/homebrew/opt/libxml2/lib -L$HOME/homebrew/opt/readline/lib" \
    CPPFLAGS="$CPPFLAGS -I$HOME/homebrew/opt/libxml2/include -I$HOME/homebrew/opt/readline/include" \
    "$@"
}

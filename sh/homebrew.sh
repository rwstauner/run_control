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
    # CPPFLAGS="$CPPFLAGS -I$HOME/homebrew/opt/libxml2/include -I$HOME/homebrew/opt/readline/include" \
    # LDFLAGS="$LDFLAGS -L$HOME/homebrew/opt/libxml2/lib -L$HOME/homebrew/opt/readline/lib" \
    # DYLD_FALLBACK_LIBRARY_PATH="$HOME/homebrew/lib" \
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH:+$PKG_CONFIG_PATH }$HOME/homebrew/lib/pkgconfig" \
    LIBRARY_PATH="${LIBRARY_PATH:+${LIBRARY_PATH}:}$HOME/homebrew/lib" \
    CPATH="${CPATH:+${CPATH}:}$HOME/homebrew/include" \
    CPPFLAGS="${CPPFLAGS:+$CPPFLAGS }-I$HOME/homebrew/include" \
    LDFLAGS="${LDFLAGS:+$LDFLAGS }-L$HOME/homebrew/lib" \
    "$@"
}

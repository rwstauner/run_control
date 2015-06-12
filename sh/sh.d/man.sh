# If MANPATH starts or ends with a colon the system config will be pre- or appended.
export MANPATH="${MANPATH:-:}"

add_to_manpath () {
  dir="$1"
  [[ -d "$dir" ]] || return
  # If MANPATH has contents (besides the colon we added above)
  # prepend colon so we can do a simple s/:$dir// next.
  [[ -n "${MANPATH%:}" ]] && MANPATH=":${MANPATH}"
  MANPATH="$dir${MANPATH//:$dir/}"
}

# manpath will add this automatically because ~/usr/bin is in $PATH.
#add_to_manpath $HOME/usr/share/man

# Re-add this to move it up to the front of the path.
add_to_manpath $HOME/homebrew/share/man

# Get GNU coreutils without the 'g' prefix.
add_to_manpath $HOME/homebrew/opt/coreutils/libexec/gnuman

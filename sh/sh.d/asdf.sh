if test -d ~/.asdf; then
  export ASDF_DIR="$HOME/.asdf"
  source_rc_files "$ASDF_DIR/asdf.sh"
fi

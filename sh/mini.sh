#!/bin/sh

include () {
  echo "# ${1##*/}"

  perl -lne '
    # Skip comments and blank lines.
    next if /^\s*(#.*)?$/;

    # Warn if a source call is found.
    warn "!: $_" if /(^|\s)(\.|source)\s+/;

    print;
  ' "$1"
}

lazy_source () {
  local rc="$1"
  echo "# load $rc"
  echo "test -r $rc && source $rc"
}

dir=${0%/*/*}

# Load `term.sh` first (see sh/loader.sh).
include $dir/sh/term.sh

# Then `sh.d/*`.
# Sh doesn't do arrays.
for rc in \
  aliases \
  \#functions \
  grep \
  lang \
  less \
  ls \
  vim \
    ; do
  # Skip "commented" lines.
  [ "${rc%%[!#]*}" = "#" ] || \
  include "$dir/sh/sh.d/$rc.sh"
done

# Always check for a local file.
lazy_source '~/.shrc.local'

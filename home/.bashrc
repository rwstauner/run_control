# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
# .bashrc

function source_rc_files () {
  local rc
  for rc in "$@"; do
    [[ -f "$rc" ]] && [[ -r "$rc" ]] && source "$rc"
  done
}

# Source global definitions
source_rc_files /etc/bash.bashrc /etc/bashrc

# different semantics than the typical pathmunge()
function add_to_path () {
  local after=false dir
  if [[ "$1" == "--after" ]]; then after=true; shift; fi
  for dir in "$@"; do
    if [[ -d "$dir" ]] && ! echo "$PATH" | grep -qE "(^|:)$dir(:|$)"; then
      if $after; then PATH="$PATH:$dir"; else PATH="$dir:$PATH"; fi
    fi
  done
}

# add_to_path /opt/*/bin
add_to_path /opt/vagrant/bin
add_to_path /opt/imagemagick/bin
add_to_path $HOME/devel/linux $HOME/bin/contrib $HOME/bin

  if which notify-send &> /dev/null; then
    # copied from ubu 12.04 default .bashrc:
    # Add an "alert" alias for long running commands.  Use like so:
    #   sleep 10; alert
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
  fi

  function astronomy_picture() { pushd /monster/media/images/astronomy/; wget "$*"; display `basename "$*"`; popd; }

  # TODO: url-encoding
  function browse_local_file() { firefox "file://`full_path $1`"; }

  function scan_pdf () {
    scan_dir=`mktemp -d /tmp/scan.XXXXXX`
    (cd "$scan_dir"; hp-scan --grey --size=letter --adf -r 200)
    mv  "$scan_dir/hpscan001.pdf" "$1"
  }

  # don't barf all over my terminal and make me 'reset'
  for cmd in evince eog; do
    eval "function $cmd () { echo 'redirecting $cmd...'; command $cmd \"\$@\" &> /dev/null & }"
  done

source_rc_files ~/.bashrc.d/* ~/.bashrc.local $EXTRA_BASHRC

#unset -f add_to_path source_rc_files

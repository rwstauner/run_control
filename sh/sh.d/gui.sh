# these are only useful on machines running X

if [[ -n "$DISPLAY" ]]; then

  #if which notify-send &> /dev/null; then
    # copied from ubu 12.04 default .bashrc:
    # Add an "alert" alias for long running commands.  Use like so:
    #   sleep 10; alert
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
  #fi

  # TODO: url-encoding
  browse_local_file () {
    ${BROWSER:-firefox} "file://`full-path $1`"
  }

  show_text () {
    [[ -z "$SYMBOLA_FONT" ]] && SYMBOLA_FONT="`ls ~/.fonts/Symbola*.?tf | tail -n 1`"
    local text=''
    if [[ $# -gt 0 ]]; then
      text="$*";
    else
      while read; do
        text="$text${text:+$'\n'}$REPLY";
      done;
    fi
    convert -font "$SYMBOLA_FONT" -pointsize 150 label:"$text" x:
  }

  qrencode-display () {
    qrencode -o - "$@" | display -
  }

  guni () {
    uni "$@" | show_text
  }

  # don't barf all over my terminal and make me 'reset' (nor take it hostage)
  for cmd in \
    acroread \
    eog \
    evince \
    gimp \
    gthumb \
    libreoffice \
    ristretto \
      ; do
    eval "$cmd () { echo 'redirecting $cmd...'; command $cmd \"\$@\" &> /dev/null & }"
  done

fi

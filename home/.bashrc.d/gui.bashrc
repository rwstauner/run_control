# these are only useful on machines running X

if [[ -n "$DISPLAY" ]]; then

  #if which notify-send &> /dev/null; then
    # copied from ubu 12.04 default .bashrc:
    # Add an "alert" alias for long running commands.  Use like so:
    #   sleep 10; alert
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
  #fi

  # TODO: url-encoding
  function browse_local_file() { ${BROWSER:-firefox} "file://`full_path $1`"; }

  function display_text () {
    local text=''
    if [[ $# -gt 0 ]]; then
      text="$*";
    else
      while read; do
        text="$text${text:+$'\n'}$REPLY";
      done;
    fi
    convert -font ~/.fonts/Symbola605.ttf -pointsize 150 label:"$text" x:
  }

  # don't barf all over my terminal and make me 'reset'
  for cmd in evince eog; do
    eval "function $cmd () { echo 'redirecting $cmd...'; command $cmd \"\$@\" &> /dev/null & }"
  done

fi
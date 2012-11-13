if [[ "$PS1" ]] && [[ "${TERM:-dumb}" != "dumb" ]]; then
# always use a terminal mutliplexer

# NOTE: tmux is particular about $TERM ("xterm" outside, "screen" inside)
[[ -z "$MULTIPLEXER" ]] && [[ -n "$TMUX" ]] && export MULTIPLEXER=tmux

# TODO: find an api to ask for terminfo entry (or make a function) and downgrade to plain if necessary

  term_plain=${TERM%%-*color}
  # do 256 if supported...
  desired_term=${TERM%%-*color}-256color
  terminfo_entry="terminfo/${desired_term:0:1}/$desired_term"
  if [[ -e "/lib/$terminfo_entry" ]] ||
     [[ -e "/usr/share/$terminfo_entry" ]]; then
    TERM="$desired_term"
  else
    echo "terminfo for $desired_term not found!"
    # just leave it the way it was; TERM=$term_plain
  fi
  unset desired_term terminfo_entry term_plain

  #if [[ "$TERM" == 'screen' ]]; then
    #export TERM=xterm
    #export GNU_SCREEN_TERM=xterm
  if [[ -z "$TMUX" && -z "$GNU_SCREEN" ]]; then
    # remind me that i'm not using a terminal multiplexer
    if which screen &> /dev/null; then
      echo '  screen:'
      screen -ls
    fi
    echo '  tmux:'
    tmux list-sessions
    echo
  fi
fi

# Move tmate socket to separate var so we can use tmux within it.
if [[ $TMATE = 1 ]] && [[ -n $TMUX ]]; then
  TMATE=$TMUX
  unset TMUX

  tmate () {
    TMUX=$TMATE command tmate "$@"
  }
fi

if [[ -z $TMUX ]]; then
  return
fi

alias capture-last-output=$HOME/run_control/tmux/capture-from-last-prompt

capture-last-prompt () {
  CAPTURE_PROMPT=1 capture-last-output "$@"
}

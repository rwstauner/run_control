if [[ -z $TMUX ]]; then
  return
fi

alias capture-last-output=$HOME/run_control/tmux/capture-from-last-prompt

capture-last-prompt () {
  CAPTURE_PROMPT=1 capture-last-output "$@"
}

# Use git for faster finding.
# export FZF_DEFAULT_COMMAND='
#   (git ls-tree -r --name-only HEAD ||
#    find . -path "*/\.*" -prune -o -type f -print -o -type l -print |
#       sed s/^..//) 2> /dev/null'
# This is evaluated by the shell so don't use functions or aliases that expect tty output.
export FZF_DEFAULT_COMMAND='command rg --files'

export FZF_DEFAULT_OPTS="
  --history $HOME/.fzf.history
  --bind 'ctrl-f:page-down,ctrl-b:page-up,ctrl-s:toggle-sort,ctrl-o:jump'
"
#--preview 'echo ${(q):-{}}' --preview-window=down:2


# Restore ^r and put fzf hist on another key.
bindkey '^R' history-incremental-search-backward
bindkey '^X^H' fzf-history-widget


_fzf_post_process_fallback () {
  # TODO: fallback command that lets you pick whole line vs field
  # what about multiple lines?
  cat
}

# Make it easy to overwrite.
_fzf_post_process_custom () {
  _fzf_post_process_fallback
}

_fzf_post_process () {
  local cmd="$1"
  case "$cmd" in
    grep\ *|git\ grep\ *|rg\ *)
      # Strip everything after "file:line".
      perl -pe 's/^(.+?:(\d+)?).*/$1/; s/:$//'
      ;;
    git\ st|git\ status)
      # If there's a "(modified|new file):" in front of the path, strip it.
      perl -pe 's/^\s*[^:]+:\s*(.+)/$1/'
      ;;
    git\ diff*|git\ ix*)
      perl -pe 's{^(?:.* )?[ab]/(.+)}{$1}'
      ;;
    git\ branch*|git\ bv*|git\ bav*)
      perl -pe 's{^[ *] (?:remotes/origin/)?(\S+)\s+.+}{$1}'
      ;;
    docker\ images*)
      # image:tag
      # awk '{ if ($2 == "<none>") { print $1 } else { printf "%s:%s\n", $1, $2 } }'
      awk '{ print $3 }'
      ;;
    docker\ ps*)
      # Just the container id.
      awk '{ print $1 }'
      ;;
    docker\ volume\ ls)
      # Just the name.
      awk '{ print $2 }'
      ;;
    *)
      _fzf_post_process_custom "$cmd"
      ;;
  esac
}

# FZF the contents of the current tmux pane.
__fzf-tmux-pane () {
  local last="${psvar[1]}" # Set by custom prompt hooks. Alternative: `fc -l -1 | cut -f 3- -d ' '`
  local cmd="${FZF_TMUX_PANE_CMD:-$HOME/run_control/tmux/capture-from-last-prompt -e}"
  # Get output before fzf switches to alternate screen.
  # (The start order of commands in a pipeline is non-deterministic.)
  local output="$(eval $cmd)"
  fzf +s --tac -m --header=tmux-capture-pane --anis <<<"$output" | _fzf_post_process "$last" | while read item; do
    # TODO: s/.+?:\d+:\K.+//
    # TODO: might not want the q
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

fzf-tmux-pane-widget() {
  LBUFFER="${LBUFFER}$(__fzf-tmux-pane)"
  local ret=$?
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}

zle     -N   fzf-tmux-pane-widget
bindkey '^T' fzf-tmux-pane-widget

# Move fzf find file to ^F since we put tmux on ^T.
FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
#export FZF_CTRL_T_COMMAND='command rg --files --glob="!*.xyz"'
  # local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . \\( -path '*/\\.*' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
  #   -o -type f -print \
  #   -o -type d -print \
  #   -o -type l -print 2> /dev/null | sed 1d | cut -b3-"}"
bindkey '^F' fzf-file-widget

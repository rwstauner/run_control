source_rc_files ~/.fzf.zsh


# Use git for faster finding.
export FZF_DEFAULT_COMMAND='
  (git ls-tree -r --name-only HEAD ||
   find . -path "*/\.*" -prune -o -type f -print -o -type l -print |
      sed s/^..//) 2> /dev/null'


export FZF_DEFAULT_OPTS="
  --history $HOME/.fzf.history
  --bind 'ctrl-f:page-down,ctrl-b:page-up,ctrl-s:toggle-sort,ctrl-o:jump'
"
#--preview 'echo ${(q):-{}}' --preview-window=down:2


# Restore ^r and put fzf hist on another key.
bindkey '^R' history-incremental-search-backward
bindkey '^X^H' fzf-history-widget

_fzf_post_process () {
  cmd="$1"
  case "$cmd" in
    ag\ *|grep\ *|git\ grep\ *)
      # Strip everything after "file:line".
      perl -pe 's/^(.+?:(\d+)).*/$1/'
      ;;
    git\ st|git\ status)
      # If there's a "(modified|new file):" in front of the path, strip it.
      perl -pe 's/^\s*[^:]+:\s*(.+)/$1/'
      ;;
    docker\ ps*)
      # Just the container id.
      awk '{ print $1 }'
      ;;
    *)
      cat
      ;;
  esac
}

# FZF the contents of the current tmux pane.
__fzf-tmux-pane () {
  local last="${psvar[1]}" # Set by custom prompt hooks. Alternative: `fc -l -1 | cut -f 3- -d ' '`
  # TODO: other options?
  # `-S 0` visible, `-S -10` ten lines in hist, `-S -` beginning
  # maybe -S - | perl -ne 'push @l, $_; @l = () if /^💥/; END { print @l }'
  # -J to wrap and preserve whitespace
  local cmd="tmux capture-pane -p"
  # Use tail to ignore the last two lines (next prompt).
  # TODO: strip blank lines at tail
  eval "$cmd | head -n -2 | $(FZF_TMUX_HEIGHT=90% __fzfcmd) +s --tac -m --header=tmux-capture-pane" | _fzf_post_process "$last" | while read item; do
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
  # local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . \\( -path '*/\\.*' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
  #   -o -type f -print \
  #   -o -type d -print \
  #   -o -type l -print 2> /dev/null | sed 1d | cut -b3-"}"
bindkey '^F' fzf-file-widget

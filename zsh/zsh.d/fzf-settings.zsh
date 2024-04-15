# Use git for faster finding.
# export FZF_DEFAULT_COMMAND='
#   (git ls-tree -r --name-only HEAD ||
#    find . -path "*/\.*" -prune -o -type f -print -o -type l -print |
#       sed s/^..//) 2> /dev/null'
# This is evaluated by the shell so don't use functions or aliases that expect tty output.
# Don't bother to sort as fzf has its own sort algorithms (and will reorder as you type).
export FZF_DEFAULT_COMMAND='command rg --files'

# --expect=key will print key on first line of results
# --cycle
# available: ctrl-o ctrl-q ctrl-r ctrl-s ctrl-v
export FZF_DEFAULT_OPTS="
  --history $HOME/.fzf.history
  --filepath-word
  --bind 'ctrl-f:page-down,ctrl-b:page-up,ctrl-s:toggle-sort,ctrl-o:jump'
  --bind 'alt-up:last,alt-down:first'
  --bind 'ctrl-g:jump'
"


# Restore ^r and put fzf hist on another key.
bindkey '^R' history-incremental-search-backward
bindkey '^X^H' fzf-history-widget


_fzf_post_process_fallback () {
  # TODO: fallback command that lets you pick whole line vs field
  # what about multiple lines?
  # or just use awk '{print $1}'
  cat
}

# Make it easy to overwrite.
if ! whence _fzf_post_process_custom >/dev/null; then
  _fzf_post_process_custom () {
    _fzf_post_process_fallback
  }
fi

_fzf_post_process () {
  local cmd="$1"
  case "$cmd" in
    grep\ *|git\ grep\ *|rg\ *)
      # Strip everything after "file:line".
      perl -pe 's/^(.+?:(\d+)?).*/$1/; s/:$//'
      ;;
    git\ st|git\ status|git\ stash\ pop*)
      # If there's a "(modified|new file):" in front of the path, strip it.
      perl -pe 's/^\s*[^:]+:\s*(.+)/$1/'
      ;;
    git\ diff*|git\ ix*|git\ adp|git\ log*|git\ last*)
      perl -pe 's{^(?:.* )?[ab]/(.+)}{$1}; s{\| \d+ [+-]+}{};'
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
    lf)
      awk '{ print $9 }'
      ;;
    lf\ *)
      # File name with dir (last arg that doesn't start with a dash) prepended.
      local dir i
      for i in "${(s: :)cmd#lf }"; {
        if ! [[ "$i" == -* ]]; then
          # If the arg contains a glob (foo/bar/*.txt) then likely all the
          # entries will have the path on them already (so don't do anything).
          if ! [[ "$i" == *\** ]]; then
            dir="$i"
          fi
        fi
      }
      # Don't use $9 in case the filename has spaces: Instead remove the first 8 columns.
      awk -v PREFIX="$dir${dir:+/}" '{ sub("([^[:space:]]+ +){8}", ""); print PREFIX $0 }'
      ;;
    *)
      _fzf_post_process_custom "$cmd"
      ;;
  esac
}

# FZF the contents of the current tmux pane.
__fzf-tmux-pane () {
  local cmd="${FZF_TMUX_PANE_CMD:-CAPTURE_PROMPT=1 $HOME/run_control/tmux/capture-from-last-prompt -e}"

  # Get output before fzf switches to alternate screen.
  # (The start order of commands in a pipeline is non-deterministic.)
  local output="$(eval $cmd)"
  # Get the prompt from the first line to determine the command used
  # so we can customize the post-processor.
  local last="$(perl -pe 's/\e\[.+?[a-z]//g; s/^\S\s+//;' <<<"${output%%$'\n'*}")"
  output="${output#*$'\n'}"

  # Allow updating the post-process filter dynamically in fzf.
  local filter="$(mktemp -t fzf.XXXXXX)"
  local default_filter
  if [[ -d ~/run_control ]]; then
    default_filter="~/run_control/zsh/fzf-post-process ${(q)last}"
  else
    # mini
    default_filter="source ~/.zshrc 2>/dev/null; _fzf_post_process ${(q)last}"
  fi
  echo "$default_filter" >! "$filter"
  local def_filter="if [[ {q} == '' ]]; then echo ${(q)default_filter}; elif [[ {q} =~ '^([\$][0-9]+ *)+\$' ]]; then printf \"awk '{ print %s }'\n\" {q}; else echo {q}; fi >! $filter"
  local end_cmd='clear-query+refresh-preview+enable-search+change-prompt(> )'
  local fzf_args=(
    +s --tac -m
    --header="$last"
    --ansi
    --preview-window up,1 --preview "echo {} | eval \$(<$filter) | while read item; do echo \${(q)item}; done"
    --bind 'ctrl-t:disable-search+change-prompt(: )'
    --bind "ctrl-x:execute-silent@$def_filter@+$end_cmd"
  )
  local fzf_output="$(fzf "${fzf_args[@]}" <<<"$output")"

  if [[ -n "$fzf_output" ]]; then
    eval "$(<$filter)" <<<"$fzf_output" | while read item; do
      local qitem="${(q)item}"
      [[ "${qitem:0:2}" == "\\~" ]] && qitem="${qitem/\\/}"
      echo -n "${qitem} "
    done
  fi
  local ret=$?
  /bin/rm -f "$filter"
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

# ~/.fzf.zsh {{{
# Setup fzf
# ---------
add_to_path ~/usr/fzf/bin

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/usr/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
() {
  local i
  for i in \
    "$HOME/usr/fzf/shell/key-bindings.zsh" \
    "/usr/share/doc/fzf/examples/key-bindings.zsh" \
  ; do
    if [[ -r "$i" ]]; then
      source "$i" && break
    fi
  done
}
# }}}

# Enable powerful prompt sequences.
setopt prompt_subst
setopt prompt_percent

# Start prompt on its own line. \o/
setopt prompt_cr
setopt prompt_sp

# Make rprompt disappear so we can copy/paste output.
setopt transient_rprompt

# Influenced by http://www.paradox.io/posts/9-my-new-zsh-prompt
# and the zsh prompt themes bart and fade.

# Make $SECONDS a floating point to get microseconds.
typeset -F SECONDS

# Since $SECONDS don't always seem to stay floating point, try $EPOCHREALTIME.
zmodload zsh/datetime

# Initialize.
ZSH_COMMAND_STARTED=${EPOCHREALTIME:-$SECONDS}

_rwstauner_before_prompt () {
  # Only update if a new command has been executed.
  if [[ -z "$ZSH_COMMAND_TOOK" ]]; then
    ZSH_COMMAND_TOOK=$(( ${EPOCHREALTIME:-$SECONDS} - $ZSH_COMMAND_STARTED ))

    # Format the elapsed time.
    psvar[2]=`format-elapsed-time $ZSH_COMMAND_TOOK`
  fi
}

_rwstauner_before_execute () {
  ZSH_COMMAND_STARTED=${EPOCHREALTIME:-$SECONDS}

  # Reset this until the next command.
  ZSH_COMMAND_TOOK=''

  # Remember the command we're executing.
  psvar[1]="$1"
}

add-zsh-hook precmd  _rwstauner_before_prompt
add-zsh-hook preexec _rwstauner_before_execute

# Some fun characters:
# ∷ ⎇  ⬕ 🚀 😎 🔥 🔚 💥 👻 🐧 🐾 🏁 🎃 🍪 🌵 🌉 🌀 🃟 🐲 💣 ☃⛄ ⛇

typeset -a my_prompt
my_prompt=(
  #'💥 '

  # user
  #'%{%F{blue}%}%n'
  # @
  #'%{%F{130}%}🌀'
  #'%{%F{228}%}💥 '
  # host
  '%{%F{green}%}%m%{%f%}'

  #'%{%F{246}%}🐾%{%f%}'
  '%{%F{216}%}🍪%{%f%} '

  # Tilde-translated directory, trailing n components, prefixed by ellipsis.
  '%{%F{cyan}%}%30<…<%(4~,…,)%3~%<<%{%f%}'

  # Warn if privileged.
  '%(!:%{%F{red}%B%S%} 💀 %{%s%b%}:)'

  # Backgroundjobs
  '%(1j;%{%B%F{cyan}%}%j⚙%{%f%b%} ;)'

  #%L $SHLVL

  '%{%B%F{green}%}🌵%{%f%b%} '

  # Time
  '%{%F{111}%}%*%{%f%}'

  '%{%F{159}%}👻 '

  # Show last command (and exit status if non-zero).
  '%{%F{139}%}%30>…>%1v%<<%(?:: %{%B%F{202}%}🎃 %?%{%f%b%})%{%f%}'

  '🐧'

  # Elapsed time of last command.
  '%{%F{135}%}%2v%{%f%}'

  # Put prompt character on a line by itself.
  $'\n$ '
)

PROMPT="${(j,,)my_prompt}"
unset my_prompt

RPROMPT='$(git_prompt_info)'

# zsh/Src/utils.c
# Put a space on each side to get enough bg color.
PROMPT_EOL_MARK="%S 🔚 %s"

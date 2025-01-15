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

  # Set title.
  #printf $'\e]0;%s\a' "${${(s: :)1}[1]}"
}

autoload -U add-zsh-hook

add-zsh-hook precmd  _rwstauner_before_prompt
add-zsh-hook preexec _rwstauner_before_execute

_rwstauner_git_prompt_info () {}
_rwstauner_cd_git_info () {}

if whence git_prompt_info &> /dev/null; then
  #_last_git_dir=''
  _rwstauner_cd_git_info () {
    # Instead of checking git after every command,
    # decide whether to enable it when we change in to a dir.
    local git_dir="`git rev-parse --git-dir 2> /dev/null`"

    #if [[ -n "$git_dir" ]] && [[ "$git_dir" != "$_last_git_dir" ]]; then
    if [[ -n "$git_dir" ]] && ! [[ "$(git config custom.no-prompt-info)" = "true" ]]; then
      _rwstauner_git_prompt_info () { git_prompt_info; }
      # _rwstauner_git_prompt_info () {
      #   local tfenv="$(cat .terraform/environment 2>/dev/null)"
      #   # TODO: hook this to actually running (or typing) terraform
      #   echo "$(git_prompt_info) ${tfenv:+"%{%F{178}%}⛈  «"}$tfenv${tfenv:+"»%{%f%}"}";
      # }
    else
      _rwstauner_git_prompt_info () {}
    fi

    #_last_git_dir="$git_dir"
  }

  add-zsh-hook chpwd   _rwstauner_cd_git_info
fi

# Some fun characters:
# ∷ ⎇  ⬕ 🚀 😎 🔥 🔚 💥 👻 🐧 🐾 🏁 🎃 🍪 🌵 🌉 🌀 🃟 🐲 💣 ☃⛄ ⛇

_rwstauner_set_prompt () {

  _rwstauner_cd_git_info

typeset -a my_prompt
my_prompt=(
  $'%{\e]133;A\a%}' # indicate start of prompt

  # Whitespace after the reset gets swallowed so put a space before it.
  $'\e[1m🤖 \e[0m'

  # Set cursor as steady block.
  # $'\e[2 q'

  # Set title
  #$'\e]0;zsh\a'

  #'💥 '

  # user
  #'%{%F{blue}%}%n'
  # @
  #'%{%F{130}%}🌀'
  #'%{%F{228}%}💥 '
  # host
  '%{'${PROMPT_HOST_COLOR:+%B}'%F{'"${PROMPT_HOST_COLOR:-green}"'}%}'${PROMPT_HOSTNAME:-%m}'%{%f'${PROMPT_HOST_COLOR:+%b}'%}'

  '%{%F{216}%}'"${SSH_CONNECTION:+ ↤}${SSH_CONNECTION%% *}"'%{%f%} '

  #'%{%F{246}%}🐾%{%f%}'
  '%{%F{216}%}🍪%{%f%} '

  # Tilde-translated directory, trailing n components, prefixed by ellipsis.
  '%{%F{cyan}%}%30<…<%(4~,…,)%3~%<<%{%f%}'

  # Warn if privileged.
  '%(!:%{%F{red}%B%S%} 💀 %{%s%b%}:)'

  # Backgroundjobs
  '%(1j; %{%B%F{cyan}%}⚙ %j%{%f%b%} ;)'

  #%L $SHLVL
  ' 📺%{%B%F{042}%}%l%{%f%b%}' # line (tty)

  '🌵 '

  # Time
  '%{%F{111}%}%*%{%f%}'

  '%{%F{159}%}👻 '

  # Show last command (and exit status if non-zero).
  '%{%F{139}%}%30>…>%1v%<<%(?:: %{%B%F{202}%}🎃 %?%{%f%b%})%{%f%}'

  '🐧 '

  # Elapsed time of last command.
  '%{%F{135}%}%2v%{%f%}'

  # Docker env.
  '${DOCKER_MACHINE_NAME:+ }%{%F{31}%}$DOCKER_MACHINE_NAME%{%f%}'

  # Put prompt character on a line by itself.
  # Zsh/zle seems much better than bash/readline about having "hidden" bytes.
  # $ › 〉❭ ❯ ❱ ⧽
  $'\n%(!.%{%K{red}%}#%{%k%}.%{%B%F{031}%}💥%{%f%b%})'

  $'%{\e]133;B\a%}' # indicate end of prompt
)

if [[ -n "$NVIM_LISTEN_ADDRESS" ]]; then
  RPROMPT='%{%B%F{202}%}« neovim »%{%f%}'
  # my_prompt[1]='✏ '
else
  RPROMPT='$(_rwstauner_git_prompt_info)'
fi
PROMPT="${(j,,)my_prompt}"
unset my_prompt

}

_rwstauner_set_prompt

# zsh/Src/utils.c
# Put a space on each side to get enough bg color.
PROMPT_EOL_MARK="%S 🔚 %s"

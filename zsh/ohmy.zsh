# Path to your oh-my-zsh installation.
export ZSH=$HOME/run_control/zsh/ext/oh-my-zsh
test -d "$ZSH" || return

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.

# Agnoster looks cool but it requires a special font.
#ZSH_THEME=agnoster
#ZSH_THEME=gnzh
: ${ZSH_THEME:=rwstauner}

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/run_control/zsh/custom

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# TODO:
# common-aliases
# debian
# dirhistory
# git # loads a ton of aliases i don't plan on using.
# golang
# extract
# jump
# lol # read for a laugh
# nyan # ditto
# per-directory-history
# perl # not useful enough
# profiles # for custom-host files (or domain-based)
# systemadmin # some cool commands but i don't need them all the time
# tmux # doesn't sound like it adds value for me (mostly about auto-starting).
  #vi-mode
# zsh_reload
plugins=(
  cp
  colorize
  docker
  docker-compose

  # We load this plugin later.
  #history-substring-search

  # npm
  # pip
  # python
  # pylint
  rsync
  safe-paste
  urltools
  # vagrant
  # virtualenv
)

# Don't load OMZ libs we don't want to use.
skip_omz_lib=(
  aliases
  bzr
  directories
  history
  nvm
  prompt_info_functions
)

source () {
  [[ "$1" =~ "$ZSH/lib/(${(j:|:)skip_omz_lib}).zsh" ]] && return
  builtin source "$@"
}

source $ZSH/oh-my-zsh.sh
omz=$?

# Always do these.
unset skip_omz_lib
unset -f source
unalias _ # alias for sudo

# If omz failed, return early and preserve exit code.
[[ $omz -eq 0 ]] || return $omz

# User configuration

autoload -U add-zsh-hook

# Remove these hooks so they don't even run (better than DISABLE_AUTO_TITLE).
add-zsh-hook -d precmd  update_terminalapp_cwd
add-zsh-hook -d precmd  omz_termsupport_precmd
add-zsh-hook -d preexec omz_termsupport_preexec


# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Merge made by octopus.
ZSH_THEME_GIT_PROMPT_PREFIX='%{%F{178}%}🐙 «'
ZSH_THEME_GIT_PROMPT_SUFFIX='»%{%f%}'

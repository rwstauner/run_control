shopt -s checkwinsize

# bash history
shopt -s histappend histreedit histverify

HISTCONTROL='ignoreboth:erasedups'

HISTIGNORE='oplop-v ?*:tmux attach:tmux a:\:q'
# with erasedups ignoring these doesn't seem all that useful:
# # forget commands that are simple and generic (no args)
# HISTIGNORE='fc *:history:l[slfh]:cd:[bf]g:vim:pushd:popd'
# #_hist_ignore_git=":amend:civ:status:st:s:adp:add -p:log:lg:logst:log -p:ls-files:push:pull:pum"
# HISTIGNORE="$HISTIGNORE${_hist_ignore_git//:/:git }"
# unset _hist_ignore_git

HISTFILESIZE=9000 HISTSIZE=9000
export HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S  '

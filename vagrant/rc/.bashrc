[[ "`pwd`" == "$HOME" ]] && [[ "$SHLVL" == "1" ]] && cd /vagrant

stty -ixon

export EDITOR=vim VISUAL=vim
export PAGER=less LESS=FRX

export VAGRANT_RC_DIR="$HOME/.vagrant.rc/rc"
export INPUTRC=$VAGRANT_RC_DIR/.inputrc

BRIDGEIP=`/sbin/ifconfig | perl -ne 'chomp; print "$1 " if /addr:((?!\Q10.0.2.15\E|\Q127.0.0.\E[01])\S+)\s/'`
PS1='\[\033[01;92m \u@\h:\w \033[95m$BRIDGEIP\033[92m[&\j \t $??] \033[00m\]\n\$ '

shopt -s checkwinsize

shopt -s histappend histreedit histverify
HISTCONTROL='ignoreboth:erasedups'
HISTFILESIZE=5000 HISTSIZE=5000

alias ls='ls --color=auto'
alias lf='ls -alF'

for i in rm mv cp; { alias $i="$i -iv"; }
for i in rmdir mkdir rename; { alias $i="$i -v"; }

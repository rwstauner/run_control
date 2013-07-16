stty -ixon

export VAGRANT_RC_DIR="$HOME/.vagrant.rc/rc"
export INPUTRC=$VAGRANT_RC_DIR/.inputrc

PS1='\[\033[01;092m \u@\h:\w [&\j \t $??] \033[00m\]\n\$ '

shopt -s checkwinsize

shopt -s histappend histreedit histverify
HISTCONTROL='ignoreboth:erasedups'
HISTFILESIZE=5000 HISTSIZE=5000

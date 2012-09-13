## editor of choice (Vim!)
export EDITOR=`which vim`
export FCEDIT=$EDITOR VISUAL=$EDITOR

alias vi='echo -e "use vim \007"; sleep 2; echo vim'
alias vimXcat='ex -c w\ !\ cat -c :q'
alias :sp='vim'

function vim_ack ()   { vim "+Ack $*"; }
function vim_which () { vim `which "$1"`; }

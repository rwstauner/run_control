add_to_path ~/usr/node/bin

node_global=$HOME/node/global
add_to_path $node_global/bin
#add_to_path ./node_modules/.bin

# FIXME: Is this necessary?  Is it correct?
NODE_PATH=$NODE_PATH:$node_global/lib/node_modules
export NODE_PATH

export NODE_REPL_HISTORY_FILE=$HOME/node/.hist

export NVM_DIR=$HOME/node/nvm
export NVM_LAZY_LOAD=true
export NVM_NO_USE=true
source_rc_files $HOME/node/.nvm.sh

node_global=$HOME/node/global
add_to_path $node_global/bin
#add_to_path ./node_modules/.bin

# FIXME: Is this necessary?  Is it correct?
NODE_PATH=$NODE_PATH:$node_global/lib/node_modules
export NODE_PATH
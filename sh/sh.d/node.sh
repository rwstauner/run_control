dnode () {
  [[ "$DNODE_ARGS" = "" ]] && DNODE_ARGS=()
  drunw \
    "${DNODE_ARGS[@]}" \
    -v "$HOME/.npmrc:/root/.npmrc:cached,ro" \
    -v node_modules:/src/node_modules \
    ${PORT+-p} ${PORT+$PORT:$PORT} \
    "${IMAGE:-node:lts}" "$@"
}

node () {
  NODE_PATH=`asdf which node | sed 's,bin/node,.npm/lib/node_modules,'` \
  command node "$@"
}

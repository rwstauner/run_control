# If docker-machine is installed load the env but only when docker is first used.
docker () {
  [ -d ~/.docker/machine/machines/default ] && \
    eval $(docker-machine env default)
  unset -f docker
  command docker "$@"
}

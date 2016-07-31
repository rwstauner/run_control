drun () {
  args=(
    -i --rm -v $PWD:/src -w /src
  )
  # Only specify -t if stdin is console (piping data to -t makes it mad).
  test -t 0 && args+=-t
  command docker run "${args[@]}" "$@"
}

docker-clean-images () {
  docker images -q -f 'dangling=true' | xargs -r docker rmi
}
docker-clean-containers () {
  docker ps     -q -f 'status=exited' | xargs -r docker rm
}

docker-in-docker-args () {
  if [[ -n "$DOCKER_MACHINE_IP" ]]; then
    # This won't work if the value contains a space,
    # but leaving the double quotes means they become part of the value.
    docker-machine env | perl -ne 'print " -e $1=$2 " if /export (.+?)="(.+?)"$/'
    echo -n ${DOCKER_CERT_PATH:+"-v $DOCKER_CERT_PATH:$DOCKER_CERT_PATH"}
  else
    echo ' -v /var/run/docker.sock:/var/run/docker.sock '
  fi
}

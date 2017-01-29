docker () {
  if [[ -d ~/.dinghy ]]; then
    `dinghy shellinit`
    DOCKER_MACHINE_IP=`dinghy ip`
  fi
  unset -f docker
  command docker "$@"
}

# https://github.com/docker/compose/issues/3106
export COMPOSE_HTTP_TIMEOUT=86400

docker-compose () {
  # Lazy-load docker env if not done already.
  docker version &> /dev/null

  # Redefine function and call it.
  docker-compose () {
    case "$1" in
      recreate)
        shift
        docker-compose build "$@"
        docker-compose stop  "$@"
        docker-compose rm -f "$@"
        set -- up --force-recreate -d "$@"
        ;;
      run)
        shift
        # TODO: Is there a way to persist bash history without -v?
        # Always use --rm with run.
        [[ "$1" == "--rm" ]] && shift
        set -- run --rm "$@"
        ;;
    esac

    if [[ -r .docker-compose.env ]]; then
      env $(perl -ne 'print if /^(\w+)=/ && !length $ENV{$1}' .docker-compose.env ) docker-compose "$@"
    else
      command docker-compose "$@"
    fi
  }
  docker-compose "$@"
}

drun () {
  local hist=$HOME/.bash_history.docker
  [[ -f $hist ]] || touch $hist
  args=(
    -v $hist:/root/.bash_history # persist bash history
    -v $hist:/root/.ash_history  # also sh (alpine)
    -i --rm -v $PWD:/src -w /src
  )

  # local var val
  # for var in TERM LOCALE LANG; {
  #   if [[ -n "$ZSH_VERSION" ]]; then
  #     val="${(P)var}"
  #   else
  #     val="${!var}"
  #   fi
  #   args+=(-e "$var=$val")
  # }

  # Only specify -t if stdin is console (piping data to -t makes it mad).
  test -t 0 && args+=-t
  docker run "${args[@]}" "$@"
}

# TODO: source .env.local (since dc it loads .env)
alias dc=docker-compose

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

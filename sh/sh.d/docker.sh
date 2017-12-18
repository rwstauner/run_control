docker () {
  if [[ -d ~/.dinghy ]]; then
    `dinghy shellinit`
    DOCKER_MACHINE_IP=`dinghy ip`
  fi
  unset -f docker
  command docker "$@"
}

dinghy () {
  `command dinghy shellinit`
  unset -f dinghy
  command dinghy "$@"
}

# https://github.com/docker/compose/issues/3106
export COMPOSE_HTTP_TIMEOUT=86400

docker-compose () {
  # Lazy-load docker env if not done already.
  docker version &> /dev/null

  # Redefine function and call it.
  docker-compose () {
    local filter=()
    case "$1" in
      recreate)
        shift
        # build first, then stop, remove, and recreate
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
      logt)
        shift;
        set -- logs -t "$@"
        filter=(perl -MTime::Stamp=parsegm -lp -M'5; open(my $fh, "|-", $ENV{PAGER}||"less") or die $!; select $fh; $|=1' -e '
          /^(\e\[.+?m)(\S+)\s+\|/ or next;
          ($esc, $name) = ($1, $2);
          $t{$name} ||= /(\S+Z)/ && parsegm($1);
          s/(\S+Z) \K/$s = parsegm($1); sprintf qq{%s%2.2f %2.2f\e[00m }, $esc, $s - $t{$name}, $s - $l{$name}/e;
          $l{$name} = $s;
        ')
        ;;
    esac

    set -- command docker-compose "$@"
    if [[ -r .docker-compose.env ]]; then
      shift # drop 'command'
      set -- env $(perl -ne 'print if /^(\w+)=/ && !length $ENV{$1}' .docker-compose.env) "$@"
    fi

    if [[ ${#filter} -gt 0 ]]; then
      "$@" | "${filter[@]}"
    else
      "$@"
    fi
  }
  docker-compose "$@"
}

docker-running () {
  docker ps -f 'status=running' --format '{{ .Names }}' | grep -qFx "$1"
}

docker-ensure () {
  name="$1"
  shift
  docker inspect --type container "$name" &> /dev/null || \
    docker create --name "$name" "$@"
  docker start "$name" &> /dev/null
}

alias dexec='docker exec -it'

dssh-agent () {
  local name=ssh-agent img=whilp/ssh-agent:latest
  docker-running "$name" || {
    docker-ensure "$name" -v ssh-agent:/ssh "$img"
    echo 'ssh-add -l >&- || ssh-add' | drun --ssh-agent -v $HOME/.ssh/id_rsa:/root/.ssh/id_rsa "$img" sh
  }
  unset -f dssh-agent
}

drun () {
  local hist=$HOME/.bash_history.docker
  [[ -f $hist ]] || touch $hist
  args=(
    -v $hist:/root/.bash_history # persist bash history
    -v $hist:/root/.ash_history  # also sh (alpine)
    -v $HOME/.inputrc:/root/.inputrc # ctrl-arrows
    -i --rm -v $PWD:/src -w /src
  )

  if [[ "$1" = "--ssh"* ]]; then
    [[ "$1" = "--ssh-agent" ]] && dssh-agent
    shift;
    args+=(-v ssh-agent:/ssh -e SSH_AUTH_SOCK=/ssh/auth/sock)
  fi

  case "$*" in
    *maven*|*gradle*|*clojure*)
      args+=(-v $HOME/.m2:/root/.m2)
      args+=(-v $HOME/.m2:/home/gradle/.m2)
      args+=(-v $hist:/home/gradle/.bash_history)
      ;;
  esac

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
docker-clean-volumes () {
  comm -1 -3 \
    <(docker ps -q | while read i; do docker inspect $i | jq -r '.[] | .Mounts | .[] | .Name'| grep -vFx null; done | sort | uniq) \
    <(docker volume ls -q | sort) \
      | xargs -r docker volume rm
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

docker-stats () {
  local extra=''
  [[ $COLUMNS -ge 150 ]] && extra='{{.Container}}\t'
  docker stats --format 'table {{.Name}}\t'"${extra}"'{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.PIDs}}' "$@"
}

# https://docs.docker.com/docker-for-mac/troubleshoot/#known-issues
docker-sync-clock () {
  drun --privileged alpine sh -c 'date; echo "$1"; date -s "$1"' -- "$(date -u +'%F %T')"
}

#_ () { log=`docker inspect --format '{{.LogPath}}' $1`; c=`wc -l $log | awk '{print $1}'`; sed -i -n -e "$((c/10)),$ p" $log; }; _ $container

docker-ip () {
  # docker inspect -f '{{ .NetworkSettings.Networks.getsmart_default.IPAddress }}' "$@"
  docker inspect "$@" | jq -r '.[]|.NetworkSettings.Networks as $n | $n[ $n|keys[0] ].IPAddress'
}

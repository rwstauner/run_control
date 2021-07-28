export DOCKER_BUILDKIT=1

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
      # logs)
      #   case "$*" in
      #     *-f*|*--follow*);;
      #     *) filter=(${PAGER:-less});;
      #   esac
      #   ;;
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

alias dexec='docker exec -it -e COLUMNS -e TERM'

# dssh-agent () {
#   local name=ssh-agent img=whilp/ssh-agent:latest
#   docker-running "$name" || {
#     docker-ensure "$name" -v ssh-agent:/ssh "$img"
#     echo 'ssh-add -l >&- || ssh-add' | drun --ssh-agent -v $HOME/.ssh/id_rsa:/root/.ssh/id_rsa:cached,ro "$img" sh
#   }
#   unset -f dssh-agent
# }

drun () {
  local hist=$HOME/.bash_history.docker
  [[ -f $hist ]] || touch $hist
  args=(
    -v $hist:/root/.bash_history:cached # persist bash history
    -v $hist:/root/.ash_history:cached  # also sh (alpine)
    -v $HOME/.inputrc:/root/.inputrc:cached # ctrl-arrows
    -i --rm
  )

  if [[ "$1" = "--ssh"* ]]; then
    # [[ "$1" = "--ssh-agent" ]] && dssh-agent
    shift;
    # args+=(-v ssh-agent:/ssh -e SSH_AUTH_SOCK=/ssh/auth/sock -e GIT_SSH_COMMAND="ssh -i ~/.id_rsa -o StrictHostKeyChecking=no -l $USER")
    local sockpath=`uname | grep -q Darwin && echo /run/host-services/ssh-auth.sock || echo "$SSH_AUTH_SOCK"`
    # FIXME: this doesn't work for github.
    args+=(-v $sockpath:$sockpath -e SSH_AUTH_SOCK=$sockpath -e GIT_SSH_COMMAND="ssh -i ~/.id_rsa -o StrictHostKeyChecking=no -l $USER")
  fi

  case "$*" in
    *maven*|*gradle*|*clojure*|*lein*)
      args+=(-v $HOME/.m2:/root/.m2:cached)
      args+=(-v $HOME/.m2:/home/gradle/.m2:cached)
      args+=(-v $hist:/home/gradle/.bash_history:cached)
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
  test -t 0 && args+=(-t)
  # echo docker run "${args[@]}" "$@"
  docker run "${args[@]}" "$@"
}
drunw () {
  preargs=()
  if [[ "$1" == "--ssh" ]]; then
    shift
    preargs=(--ssh)
  fi
  drun "${preargs[@]}" -v "$PWD:/src:cached" -w /src "$@"
}

alias dc=docker-compose

docker-clean-images () {
  docker images -q -f 'dangling=true' | gxargs -r docker rmi
}
docker-clean-containers () {
  docker ps     -q -f 'status=exited' | gxargs -r docker rm
}
docker-clean-volumes () {
  comm -1 -3 \
    <(docker ps -q | while read i; do docker inspect $i | jq -r '.[] | .Mounts | .[] | .Name'| grep -vFx null; done | sort | uniq) \
    <(docker volume ls -q --filter 'dangling=true' | grep -E '[a-f0-9]{64}' | sort) \
      | gxargs -r docker volume rm
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
  case "$1" in
    --max-mem)
      docker stats --format '{{.Name}}\t{{.MemUsage}}' | perl -MTime::Stamp=localstamp -ne '
        BEGIN { $|=1; $units = { K => (1/1024), M => 1, G => 1024 }; $last = 0; }
        next unless /'"$2"'/;
        ($val, $unit) = /(\d+(?:\.\d+)?)([KMG])iB/ or next;
        $val *= $units->{$unit};
        s/^\e\[2J\e\[H/ /g;
        $_ = "${\localstamp} " . $_;
        if ($val > $last) {
          $last = $val;
          print $_;
        }
        else {
          chomp;
          print $_, "\r";
        }
      '
      return
      ;;
  esac;
  [[ $COLUMNS -ge 150 ]] && extra='{{.Container}}\t'
  docker stats --format 'table {{.Name}}\t'"${extra}"'{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.PIDs}}' "$@"
}

# https://docs.docker.com/docker-for-mac/troubleshoot/#known-issues
docker-sync-clock () {
  drun --privileged alpine sh -c 'date; echo "$1"; date -s "$1"' -- "$(date -u +'%F %T')"
}

#_ () { log=`docker inspect --format '{{.LogPath}}' $1`; c=`wc -l $log | awk '{print $1}'`; sed -i -n -e "$((c/10)),$ p" $log; }; _ $container

docker-ip () {
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

docker-dive () {
  docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    wagoodman/dive:latest "$@"
}

# TODO: eval
_find_home () {
  var="$1"
  name="$2"

  # Stop if the var is already set.
  if [[ -n "$ZSH_VERSION" ]]; then
    [[ -z "${(P)var}" ]] || return
  else
    [[ -z "${!var}"   ]] || return
  fi

  for dir in $HOME/java $HOME/opt /opt; do
  for found in $dir/$name*${ZSH_VERSION:+(N)}; do
    if [[ -d "$found" ]]; then
      while test -h "$found"; do
        found="`readlink "$found"`"
      done
      eval "export $var='$found'"
      add_to_path $found/bin
      break 2
    fi
  done
  done
}

  # prefer jdk, accept jre
  _find_home JAVA_HOME jdk
  _find_home JAVA_HOME jre

  _find_home GROOVY_HOME groovy

  _find_home GRAILS_HOME grails

unset -f _find_home

mvel_jar=`ls $JAVA_HOME/../jars/mvel*.jar${ZSH_VERSION:+(N)} 2> /dev/null | tail -n 1`
if [[ -n "$mvel_jar" ]]; then
  alias mvel="rlwrap -C mvel java -jar $mvel_jar"
fi

# TODO: eval
function _find_home () {
  var="$1"
  shift
  while [[ $# -gt 0 ]]; do
    found="`ls -d $1 2> /dev/null | tail -n 1`"
    if [[ -n "$found" ]]; then
      while test -h "$found"; do
        found="`readlink "$found"`"
      done
      eval "export $var='$found'"
      add_to_path ${!var}/bin
      break
    fi
    shift
  done
}

  # prefer jdk, accept jre
  _find_home JAVA_HOME $HOME/java/{jdk,jre}\*

  _find_home GROOVY_HOME {$HOME/java,/opt}/groovy-\*

  _find_home GRAILS_HOME {$HOME/java,/opt}/grails-\*

unset -f _find_home

mvel_jar=`ls $JAVA_HOME/../jars/mvel*.jar 2> /dev/null | tail -n 1`
if [[ -n "$mvel_jar" ]]; then
  alias mvel="rlwrap -C mvel java -jar $mvel_jar"
fi

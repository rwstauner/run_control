[[ -d "$HOME/java" ]] || return

  # prefer jdk
  JAVA_HOME="`ls -d $HOME/java/jdk* | head -n1`"

  # accept jre
[[ "$JAVA_HOME" ]] && [[ -e "$JAVA_HOME/bin/java" ]] || \
  JAVA_HOME="`ls -d $HOME/java/j* | head -n1`"

  # found any?
[[ "$JAVA_HOME" ]] && [[ -e "$JAVA_HOME/bin/java" ]] && \
  export JAVA_HOME && add_to_path $JAVA_HOME/bin

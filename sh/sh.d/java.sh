# TODO: eval

# Assume symlinks exist.

java-home-vars () {
  local name="$1" dir="$2"
  [[ -d "$dir" ]] || return
  add_to_path $dir/bin
  export $name=$dir
}

# jar-alias () {
#   local name="$1" pre="$2" post="$3"
#   local jar=$HOME/java/jars/$name.jar
#   [[ -f $jar ]] || return
#   alias $name="$pre $jar${post:+ }$post"
# }

java-home-vars JAVA_HOME ~/java/home

#jar-alias mvel 'rlwrap -C mvel java -jar' ''

# To root everything else.
SCALA_ROOT=$HOME/scala

# Enable tools (like vim) to find support files.
export SCALA_DIST=$SCALA_ROOT/scala-dist

# Actual scala installation.
export SCALA_HOME=$SCALA_ROOT/local

# Get scala.
add_to_path $SCALA_HOME/bin

# Get sbt.
add_to_path $SCALA_ROOT/sbt/bin

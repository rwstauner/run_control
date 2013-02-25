#function have_command () { which "$@" &> /dev/null; }

#have_command dict &&
  function dict () { command dict "$@" | less; }

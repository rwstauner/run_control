# Overwrite our sh function with a simpler one, because zsh is awesome.
full-path () {
  echo "$1:a"
}

# Format argument (of seconds) into separate units (up to days).
format-elapsed-time () {
  local -F sec=$1
  local -a elapsed
  local -i i top

  local -a units; units=('d' 'h' 'm')
  local -a amts;  amts=(86400 3600 60)

  for ((i=1; i <= ${#units}; i++)); do
    if (( $sec >= ${amts[$i]} )); then
      (( top = $sec / $amts[$i] ))
      (( sec = $sec - $top * $amts[$i] ))
      elapsed+="${top}${units[$i]}"
    fi
  done
  # Append remaining seconds to array after stripping trailing zeros.
  # TODO: Round this to 3 or 6 decimal places?
  elapsed+="${${sec//%0#/}%.}s"

  echo "${(j, ,)elapsed}"
}

newest () {
  # Utilize multios to print path to STDERR (for visbility) and STDOUT (for pipe).
  ls -tr "$@" | tail -n 1 1>&2 | cat
}

diff-with () {
  code="$1"; shift
  diffgit =($code $1) =($code $2)
}

clj () {
  if [[ $# -eq 0 ]]; then
    clojure -M:my-repl
  else
    command clj "$@"
  fi
}

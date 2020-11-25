clj () {
  if [[ $# -eq 0 ]]; then
    clojure -M:cljfmt:nrepl:rebel:tools/repl -i ~/.clojure/src/my_repl.clj -m nrepl.cmdline -i -f my-repl/repl
  else
    command clj "$@"
  fi
}

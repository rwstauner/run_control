clj () {
  if [[ $# -eq 0 ]]; then
    clojure -M:cljfmt:nrepl-dep:rebel:tools/repl -i ~/.clojure/src/my_repl.clj -m nrepl.cmdline -i -f my-repl/repl
  else
    command clj "$@"
  fi
}
alias cljs='clojure -M:rebel-cljs'

-rlwrap! bb
alias bbj='bb "(json/parse-stream *in* true)" | bb'

export BABASHKA_PRELOADS='(defmacro $$ [& args] `(let [proc ^{:inherit true} (p/$ ~@args)] (p/check proc) nil))'

# -rlwrap! shadow-cljs

# Skip npx.
# export ICED_REPL_SHADOW_CLJS_CMD='shadow-cljs -A:weasel'
# alias iced=$HOME/.vim/plugged/vim-iced/bin/iced

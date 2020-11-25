(ns my-repl
  (:require
   [rebel-readline.clojure.main :as rebel]))

(defmacro with-ns
  [new-ns & body]
  `(let [previous# (-> *ns* str symbol)]
     (try
       (in-ns ~new-ns)
       ~@body
       (finally
         (in-ns previous#)))))

(defn user-ns
  []
  (with-ns 'user
    (require '[clojure.repl :refer [apropos dir doc find-doc pst source]]
             '[clojure.tools.namespace.repl :refer [refresh refresh-all]])))

(defn repl
  [& _]
  (user-ns)
  (rebel/-main)
  (System/exit 0))

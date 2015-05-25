(defproject bocko-ios "0.1.0"
  :description "Use Bocko on iOS"
  :dependencies [[org.clojure/clojure "1.7.0-RC1"]
                 [org.clojure/clojurescript "0.0-3269"]
                 [bocko "0.3.0"]
                 [org.omcljs/ambly "0.3.0"]]
  :plugins [[lein-cljsbuild "1.0.6"]]
  :source-paths ["src"]
  :clean-targets ["target" "out"]
  :cljsbuild {:builds {:dev
                       {:source-paths ["src"]
                        :compiler     {:output-to      "target/out/main.js"
                                       :output-dir     "target/out"
                                       :optimizations  :none}}
                       :rel
                       {:source-paths ["src"]
                        :compiler     {:output-to     "target/out/main.js"
                                       :optimizations :advanced
                                       :externs       ["externs.js"]
                                       :pretty-print  false
                                       :pseudo-names  false}}}})

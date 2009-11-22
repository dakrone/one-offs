#!/Users/hinmanm/bin/clj
; Index of Coincidence
(use '[clojure.contrib.duck-streams :only (reader file-str)])
(use '[clojure.contrib.str-utils2 :only (join)])

(defn ioc-base
  "Returns the Index of Coincidence for a given shift and list of
   numbers as a percentage."
  [s n]
  (let [pairs (partition s 1 n)
        size (count n)]
    ;(println pairs)
    (float (* 100 (/ (reduce + (map #(if (= (first %) (last %)) 1 0) pairs)) size)))))

(defn ioc-string
  [shift string]
  (ioc-base (inc shift) (partition 1 string)))

; Reading bytes
(defn bytes
  "Returns all bytes from rdr as a lazy sequence."
  [rdr]
  (let [res (. rdr read)]
    (if (= res -1)
      (do (. rdr close) nil)
      (lazy-seq (cons (str (char res)) (bytes rdr))))))

(defn ioc-file
  "Prints the IoC for a given filename."
  [filename]
  (print (str "The IoC of " filename " is: "))
  (with-open [r (reader (file-str (str filename)))]
    (println (ioc-string 1 (join "" (bytes r)))))) ;; hardcoded shift of 5


(if (not (empty? *command-line-args*))
  (doseq [file *command-line-args*]
    (time (ioc-file file)))
  (println "Please specify 1 or more file(s)."))

; ./ioc.clj -- lipsum.txt

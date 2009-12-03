; Scenario:
; You have a number of files, you need to operate on each line in all the
; files, so which way is the fastest?
;
; In this case we are just counting lines, but it could be extended to
; any other function.
;
; TL;DR version: use pmap and slurp if you can, pmap and line-seq if you can't.

(ns multi-count
  (:use clojure.contrib.duck-streams))

(def *files* ["file1.txt", "file2.txt", "file3.txt", "file4.txt"])

(set! *warn-on-reflection* true)

(defn count-chars
  [filename]
  (.length (slurp filename)))

; Extremely inefficient
(defn count-chars2
  [filename]
  (with-open [f (reader filename)]
    (reduce + (map (fn [#^String s] (.length s)) (line-seq f)))))

; sequential version
(time (reduce + (map count-chars *files*)))
; "Elapsed time: 1675.371 msecs"
; 49736260

; sequential slower version (better with type hinting)
(time (reduce + (map count-chars2 *files*)))
; "Elapsed time: 3517.288 msecs" (more like ~2600 after running a few times)
; "Elapsed time: 76370.366 msecs" <-- SCRATCH THIS
; 45037540

; parallel version
(time (reduce + (pmap count-chars *files*)))
; "Elapsed time: 1469.575 msecs"
; 49736260

; parallel slower version (better with type hinting)
(time (reduce + (pmap count-chars2 *files*)))
; "Elapsed time: 1844.588 msecs" (more like ~1550 after running a few times)
; 45037540

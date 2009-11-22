(comment

  If I have the numbers:
  2 4 2 3 4 5 which would normally average (2+4+2+3+4+5)/6

  I want to average them with weights, so it will be:
  (2 + ((4 + ((2 + ((3 + ((4 + 5) / 2)) / 2)) / 2)) / 2)) / 2

  But, how with arbitrary numbers of numbers, ie 3:
  (2 + ((4 + 2 + ((3 + 4 + 5) / 3)) / 3)) / 2
)

(defn w-avg
  "Given a vector of numbers, return the left-weighted average."
  [nums]
  (reduce #(/ (+ %1 %2) 2) (reverse nums)))

(defn avg
  "Takes a list and returns average of the numbers."
  [nums]
  (/ (reduce + nums) (count nums)))

(defn averages
  "Takes a chunk size and a list of numbers to average."
  [size numbers]
  (while numbers
    (let [nums (take size numbers) ; This doesn't work because take doesn't change the array
          c (count nums)]
      (avg nums))))


(defn foo
  [size numbers]
  (loop [nums (take size (reverse numbers))
         a 0]
    (if (> 0 a)
      (avg (cons a (rest nums)))
      (avg nums))))

;;; From Chouser
(use '[clojure.contrib.seq-utils :only (partition-all)])

(defn averages [size nums]
  (let [rnums (reverse nums)
        s (partition-all (dec size) (next rnums))]
    (reduce
      (fn [avg chunk]
        (/ (reduce + avg chunk) (min (inc (count chunk)) size)))
      0
      (cons (cons (first rnums) (first s)) (next s)))))

;;; Mara's

(use '[clojure.contrib.seq-utils :only (partition-all)])

(defn avg [c] (/ (apply + c) (count c)))

(defn left-weighted-avg [c n]
  (let [reversed (reverse c)
        initial (avg (take n reversed))
        remainder (partition-all (dec n) (drop n reversed))]
    (reduce #(avg (concat [%1] %2)) initial remainder)))


;; UTILITIES ;;

(= (TupleConcat $Ev1 $Ev2) 
   (collapse (superpose ((superpose $Ev1)
                         (superpose $Ev2)))))

(= (any $Z)
   (not (== () $Z)))

(= (range $K $N)
   (If (< $K $N)
       (TupleConcat ($K) (range (+ $K 1) $N)) ()))

;; PROPOSITIONAL LOGIC ;;

(= (∧ $P $Q)
   (and $P $Q))

(= (v $P $Q)
   (or $P $Q))

(= (¬ $P)
   (not $P))

(= (⟹ $P $Q)
   (v ((¬ $P) $Q)))

(= (⟺ $P $Q)
   (∧ ($P ⟹ $Q) ($Q ⟹ $P)))

;; QUANTIFIED PREDICATES OVER INTERVALS ;;

(= (∀x $ϕ from $a to $b)
   (If (> $a $b)
       True
       (and ($ϕ $a) (∀x $ϕ from (+ $a 1) to $b))))

(= (∃x $ϕ from $a to $b)
   (If (> $a $b)
       False
       (or ($ϕ $a) (∃x $ϕ from (+ 1 $a) to $b))))

;count true
(= (Cx $ϕ from $a to $b)
   (If (> $a $b)
       0
       (let $cnt (If ($ϕ $a) 1 0)
            (+ $cnt (Cx $ϕ from (+ 1 $a) to $b)))))

;; SIGNAL TEMPORAL LOGIC ;;

;globally
(= (□ $ϕ from $a to $b at $t)
   (∀x $ϕ from (+ $t $a) to (+ $t $b)))

;finally
(= (◊ $ϕ from $a to $b at $t)
   (∃x $ϕ from (+ $t $a) to (+ $t $b)))

;until
(= (𝒰 $ϕ $ψ from $a to $b at $t)
   (any (collapse (let* (($I (range (+ $t $a) (+ $t $b)))
                         ($y (superpose $I)))
                        (If (and ($ψ $y) (∀x $ϕ from $t to $y)) thing)))))

;; SIGNAL TEMPORAL NAL

;; Truth functions
(= (Truth_c2w $c) (/ $c (- 1 $c)))
(= (Truth_w2c $w) (/ $w (+ $w 1)))
(= (Truth_Revision ($f1 $c1) ($f2 $c2)) 
   (let* (($w1 (Truth_c2w $c1)) ($w2 (Truth_c2w $c2)) ($w  (+ $w1 $w2))
          ($f (/ (+ (* $w1 $f1) (* $w2 $f2)) $w)) ($c (Truth_w2c $w)))
          ((min 1.00 $f) (min 0.99 (max (max $c $c1) $c2)))))
(= (Truth_Expectation ($f $c)) (+ (* $c (- $f 0.5)) 0.5))
(= (Truth_Observation None) (0.0 0.0))
(= (Truth_Observation True) (1.0 0.9))
(= (Truth_Observation False) (0.0 0.9))
;globally with uncertainty
(= (TVx $ϕ from $a to $b)
   (If (> $a $b)
       (Truth_Observation None)
       (Truth_Revision (Truth_Observation ($ϕ $a)) 
                       (TVx $ϕ from (+ $a 1) to $b))))

;globally
(= (□TV $ϕ from $a to $b at $t)
   (TVx $ϕ from (+ $t $a) to (+ $t $b)))

;finally
(= (◊TV $ϕ from $a to $b at $t)
   (1.0 (Truth_w2c (Cx $ϕ from (+ $t $a) to (+ $t $b)))))

(= (𝒰TV $ϕ $ψ from $a to $b at $t)
   (collapse (let* (($I (range (+ $t $a) (+ $t $b)))
                         ($y (superpose $I)))
                        (Truth_Observation (and ($ψ $y) (∀x $ϕ from $t to $y))))))

;; EXAMPLE ;;

(= (x $t) $t)
(= (ϕ $t) (< (x $t) 10))
(= (ψ $t) (< (x $t) 20))

!(□ ϕ from 1 to 4 at 0)

!(let* (($I (range 1 6))
        ($t (superpose $I)))
       (□ ϕ from 1 to 5 at $t))

!(□ ϕ from 1 to 10 at 0)

!(𝒰 ϕ ψ from 0 to 13 at 5)

!(□ ϕ from 1 to 10 at 0)
!(□TV ϕ from 1 to 10 at 0)
!(◊TV ϕ from 1 to 10 at 0)

; t-hw3.lsp
; Defines test cases for hw3.lsp
; Format: (ASSERT (EQUAL expected_answer    (function with args)))

; NOTE: do not turn this in, it uses some lisp functions not allowed in hw3
; member
(load "a-star.lsp")
(load "hw3.lsp")

; goal-test (s)
; @param s state (a k-by-k list of lists where k is an int > 0)
; @return t if no box is on a non-goal square; else nil
; # goals = # boxes
(assert (equal t (goal-test '(
    (0 0 1 1 1 1 0 0 0)
    (1 1 1 0 0 1 1 1 1)
    (1 0 0 0 3 0 0 0 1)
    (1 0 1 0 0 1 0 0 1)
    (1 0 5 0 5 1 0 0 1)
    (1 1 1 1 1 1 1 1 1)))))
; # goals > # boxes
(assert (equal t (goal-test '(
    (0 0 1 1 1 1 0 0 0)
    (1 1 1 0 0 1 1 1 1)
    (1 4 0 0 3 0 0 0 1)
    (1 0 1 0 0 1 0 0 1)
    (1 0 5 0 5 1 0 0 1)
    (1 1 1 1 1 1 1 1 1)))))
; still a regular box on the map
(assert (equal nil (goal-test '(
    (0 0 1 1 1 1 0 0 0)
    (1 1 1 0 0 1 1 1 1)
    (1 0 0 0 3 0 2 0 1)
    (1 0 1 0 0 1 2 0 1)
    (1 0 4 0 4 1 0 0 1)
    (1 1 1 1 1 1 1 1 1)))))

; next-states (s)
; @param s state (a k-by-k list of lists where k is an int > 0)
; @return a list of the possible states to go from the given state 
; test logic: up, down, left, right can either be possible or impossible
; which implies 2^4 test cases
; we don't test all 2^4 cases, just one of each
; 0 ways to move
(assert (equal (next-states '(
    (0 1 0 0 0)
    (1 3 1 2 0)
    (0 1 1 2 0)
    (1 0 4 4 1)
    (0 1 0 1 0)))   '((
    ))))
; 1 way to move
(assert (equal (next-states '(
    (0 1 0 0 0)
    (1 0 2 4 0)
    (0 1 1 2 0)
    (1 3 0 4 1)
    (0 1 0 1 0)))   '((
        ; right
        (0 1 0 0 0)
        (1 0 2 4 0)
        (0 1 1 2 0)
        (1 0 3 4 1)
        (0 1 0 1 0)
    ))))
; 2 ways to move
(setq ns1 (next-states '(
    (0 1 0 0 0)
    (1 0 0 2 0)
    (1 3 1 2 0)
    (1 0 4 0 1)
    (0 1 4 1 0))))
(assert (member '(
        ; up
        (0 1 0 0 0)
        (1 3 0 2 0)
        (1 0 1 2 0)
        (1 0 4 0 1)
        (0 1 4 1 0)
        ) ns1 :test 'equal))
(assert (member '(
        ; down
        (0 1 0 0 0)
        (1 0 0 2 0)
        (1 0 1 2 0)
        (1 3 4 0 1)
        (0 1 4 1 0)
        ) ns1 :test 'equal))
; 1101 (3 ways to move)
(setq ns3 (next-states '(
    (0 1 0 0 0)
    (1 0 2 0 0)
    (0 3 1 2 0)
    (1 0 4 4 1)
    (0 1 0 1 0))))
(assert (member '(
        ; up
        (0 1 0 0 0)
        (1 3 2 0 0)
        (0 0 1 2 0)
        (1 0 4 4 1)
        (0 1 0 1 0)
        ) ns3 :test 'equal))
(assert (member '(
        ; down
        (0 1 0 0 0)
        (1 0 2 0 0)
        (0 0 1 2 0)
        (1 3 4 4 1)
        (0 1 0 1 0)
        ) ns3 :test 'equal))
(assert (member '(
        ; left
        (0 1 0 0 0)
        (1 0 2 0 0)
        (3 0 1 2 0)
        (1 0 4 4 1)
        (0 1 0 1 0)
        ) ns3 :test 'equal))
; 1111 (4 ways to move)
(setq ns4 (next-states '(
    (0 1 0 0 0)
    (1 0 2 3 0)
    (0 0 1 2 0)
    (1 0 0 0 1)
    (0 1 0 1 0))))
(assert (member '(
        ; up
        (0 1 0 3 0)
        (1 0 2 0 0)
        (0 0 1 2 0)
        (1 0 0 0 1)
        (0 1 0 1 0)
        ) ns4 :test 'equal))
(assert (member '(
        ; down
        (0 1 0 0 0)
        (1 0 2 0 0)
        (0 0 1 3 0)
        (1 0 0 2 1)
        (0 1 0 1 0)
        ) ns4 :test 'equal))
(assert (member '(
        ; left
        (0 1 0 0 0)
        (1 2 3 0 0)
        (0 0 1 2 0)
        (1 0 0 0 1)
        (0 1 0 1 0)
        ) ns4 :test 'equal))
(assert (member '(
        ; right
        (0 1 0 0 0)
        (1 0 2 0 3)
        (0 0 1 2 0)
        (1 0 0 0 1)
        (0 1 0 1 0)
        ) ns4 :test 'equal))
; their cases
; case 1
(setq s1 (next-states '(
    (1 1 1 1 1)
    (1 0 0 4 1)
    (1 0 2 0 1)
    (1 0 3 0 1)
    (1 0 0 0 1)
    (1 1 1 1 1))))
(assert (member '(
        (1 1 1 1 1)
        (1 0 2 4 1)
        (1 0 3 0 1)
        (1 0 0 0 1)
        (1 0 0 0 1)
        (1 1 1 1 1)
        ) s1 :test 'equal))
(assert (member '(
        (1 1 1 1 1)
        (1 0 0 4 1)
        (1 0 2 0 1)
        (1 0 0 3 1)
        (1 0 0 0 1)
        (1 1 1 1 1)
        ) s1 :test 'equal))
(assert (member '(
        (1 1 1 1 1)
        (1 0 0 4 1)
        (1 0 2 0 1)
        (1 0 0 0 1)
        (1 0 3 0 1)
        (1 1 1 1 1)
        ) s1 :test 'equal))
(assert (member '(
        (1 1 1 1 1)
        (1 0 0 4 1)
        (1 0 2 0 1)
        (1 3 0 0 1)
        (1 0 0 0 1)
        (1 1 1 1 1)
        ) s1 :test 'equal))
; case 2
(setq s2 (next-states '(
    (1 1 1 1 1)
    (1 0 0 4 1)
    (1 0 2 3 1)
    (1 0 0 0 1)
    (1 0 0 0 1)
    (1 1 1 1 1))))
(assert (member '(
        (1 1 1 1 1)
        (1 0 0 6 1)
        (1 0 2 0 1)
        (1 0 0 0 1)
        (1 0 0 0 1)
        (1 1 1 1 1)
        ) s2 :test 'equal))
(assert (member '(
        (1 1 1 1 1)
        (1 0 0 4 1)
        (1 0 2 0 1)
        (1 0 0 3 1)
        (1 0 0 0 1)
        (1 1 1 1 1)
        ) s2 :test 'equal))
(assert (member '(
        (1 1 1 1 1)
        (1 0 0 4 1)
        (1 2 3 0 1)
        (1 0 0 0 1)
        (1 0 0 0 1)
        (1 1 1 1 1)
        ) s2 :test 'equal))
; case 3
(setq s3 (next-states '(
    (1 1 1 1 1)
    (1 0 0 6 1)
    (1 0 2 0 1)
    (1 0 0 0 1)
    (1 0 0 0 1)
    (1 1 1 1 1))))
(assert (member '(
        (1 1 1 1 1)
        (1 0 0 4 1)
        (1 0 2 3 1)
        (1 0 0 0 1)
        (1 0 0 0 1)
        (1 1 1 1 1)
        ) s3 :test 'equal))
(assert (member '(
        (1 1 1 1 1)
        (1 0 3 4 1)
        (1 0 2 0 1)
        (1 0 0 0 1)
        (1 0 0 0 1)
        (1 1 1 1 1)
        ) s3 :test 'equal))
; case 4
(setq s4 (next-states '(
    (1 1 1 1 1)
    (1 4 2 0 1)
    (1 0 0 0 1)
    (1 0 0 0 1)
    (1 0 5 3 1)
    (1 1 1 1 1))))
(assert (member '(
        (1 1 1 1 1)
        (1 4 2 0 1)
        (1 0 0 0 1)
        (1 0 0 3 1)
        (1 0 5 0 1)
        (1 1 1 1 1)
        ) s4 :test 'equal))
(assert (member '(
        (1 1 1 1 1)
        (1 4 2 0 1)
        (1 0 0 0 1)
        (1 0 0 0 1)
        (1 2 6 0 1)
        (1 1 1 1 1)
        ) s4 :test 'equal))


; h0
; @param s state (a k-by-k list of lists where k is an int > 0)
; @return 0
; non-goal state
(assert (equal 0 (h0 '(
    (0 0 1 1 1 1 0 0 0)
    (1 1 1 0 0 1 1 1 1)
    (1 0 0 0 3 0 2 0 1)
    (1 0 1 0 0 1 2 0 1)
    (1 0 4 0 4 1 0 0 1)
    (1 1 1 1 1 1 1 1 1)))))
; goal state
(assert (equal 0 (h0 '(
    (0 0 1 1 1 1 0 0 0)
    (1 1 1 0 0 1 1 1 1)
    (1 0 0 0 3 0 0 0 1)
    (1 0 1 0 0 1 0 0 1)
    (1 0 5 0 5 1 0 0 1)
    (1 1 1 1 1 1 1 1 1)))))


; h1 (s)
; @param s state (a k-by-k list of lists where k is an int > 0)
; @return the number of boxes not on goal positions in the given state
; 0 not on goal positions (no extra goals) 
(assert (equal 0 (h1 '(
    (0 0 1 1 1 1 0 0 0)
    (1 1 1 0 0 1 1 1 1)
    (1 0 0 0 3 0 0 0 1)
    (1 0 1 0 0 1 0 0 1)
    (1 0 5 0 5 1 0 0 1)
    (1 1 1 1 1 1 1 1 1)))))
; 0 not on goal positions (with extra goals) 
(assert (equal 0 (h1 '(
    (0 0 1 1 1 1 0 0 0)
    (1 1 1 0 0 1 1 1 1)
    (1 0 0 0 3 0 0 0 1)
    (1 0 1 0 0 1 4 4 1)
    (1 0 5 0 5 1 0 0 1)
    (1 1 1 1 1 1 1 1 1)))))
; 1 not on goal positions 
(assert (equal 1 (h1 '(
    (0 0 1 1 1 1 0 0 0)
    (1 1 1 0 0 1 1 1 1)
    (1 0 0 0 3 0 0 0 1)
    (1 0 1 2 0 1 0 0 1)
    (1 0 4 0 5 1 0 0 1)
    (1 1 1 1 1 1 1 1 1)))))
; 5 not on goal positions 
(assert (equal 5 (h1 '(
    (0 0 1 1 1 1 0 0 0)
    (1 1 1 4 2 1 1 1 1)
    (1 4 0 0 3 2 2 0 1)
    (1 4 1 0 0 1 2 0 1)
    (1 0 4 2 4 1 5 0 1)
    (1 1 1 1 1 1 1 1 1)))))



; hUID (s)
; (h804621520)
; @param s state (a k-by-k list of lists where k is an int > 0)
; @return TODO: make up a heuristic
; TODO: maybe test if it is admissible

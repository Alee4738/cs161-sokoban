;
; CS161 Hw3: Sokoban
; 
; *********************
;    READ THIS FIRST
; ********************* 
;
; All functions that you need to modify are marked with 'EXERCISE' in their header comments.
; Do not modify a-star.lsp.
; This file also contains many helper functions. You may call any of them in your functions.
;
; *Warning*: The provided A* code only supports the maximum cost of 4999 for any node.
; That is f(n)=g(n)+h(n) < 5000. So, be careful when you write your heuristic functions.
; Do not make them return anything too large.
;
; For Allegro Common Lisp users: The free version of Allegro puts a limit on memory.
; So, it may crash on some hard sokoban problems and there is no easy fix (unless you buy 
; Allegro). 
; Of course, other versions of Lisp may also crash if the problem is too hard, but the amount
; of memory available will be relatively more relaxed.
; Improving the quality of the heuristic will mitigate this problem, as it will allow A* to
; solve hard problems with fewer node expansions.
; 
; In either case, this limitation should not significantly affect your grade.
; 
; Remember that most functions are not graded on efficiency (only correctness).
; Efficiency can only influence your heuristic performance in the competition (which will
; affect your score).
;  
;
; functions, predicates, and operators allowed:
;  quote ['], car, cdr [cadadr, etc.], first, second [third, etc.], 
;  rest, cons, list, append, length, numberp, stringp, listp, atom, 
;  symbolp, oddp, evenp, null, not, and, or, cond, if, equal, defun, 
;  let, let*, =, <, >, +, -, *, /, butlast, nthcdr, count
;  Note: you are not permitted to use setq or any looping function


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; General utility functions
; They are not necessary for this homework.
; Use/modify them for your own convenience.
;

;
; For reloading modified code.
; I found this easier than typing (load "filename") every time. 
;
(defun reload()
  (load "hw3.lsp")
  )

;
; For loading a-star.lsp.
;
(defun load-a-star()
  (load "a-star.lsp"))

;
; Reloads hw3.lsp and a-star.lsp
;
(defun reload-all()
  (reload)
  (load-a-star)
  )

;
; A shortcut function.
; goal-test and next-states stay the same throughout the assignment.
; So, you can just call (sokoban <init-state> #'<heuristic-name>).
; 
;
(defun sokoban (s h)
  (a* s #'goal-test #'next-states h)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; end general utility functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; We now begin actual Sokoban code
;

; Define some global variables
(setq blank 0)
(setq wall 1)
(setq box 2)
(setq keeper 3)
(setq star 4)
(setq boxstar 5)
(setq keeperstar 6)

; Some helper functions for checking the content of a square
(defun isBlank (v)
  (= v blank)
  )

(defun isWall (v)
  (= v wall)
  )

(defun isBox (v)
  (= v box)
  )

(defun isKeeper (v)
  (= v keeper)
  )

(defun isStar (v)
  (= v star)
  )

(defun isBoxStar (v)
  (= v boxstar)
  )

(defun isKeeperStar (v)
  (= v keeperstar)
  )

;
; Helper function of getKeeperPosition
;
(defun getKeeperColumn (r col)
  (cond ((null r) nil)
	(t (if (or (isKeeper (car r)) (isKeeperStar (car r)))
	       col
	     (getKeeperColumn (cdr r) (+ col 1))
	     );end if
	   );end t
	);end cond
  )

;
; getKeeperPosition (s firstRow)
; Returns a list indicating the position of the keeper (c r).
; 
; Assumes that the keeper is in row >= firstRow.
; The top row is the zeroth row.
; The first (right) column is the zeroth column.
;
(defun getKeeperPosition (s row)
  (cond ((null s) nil)
	(t (let ((x (getKeeperColumn (car s) 0)))
	     (if x
		 ;keeper is in this row
		 (list x row)
		 ;otherwise move on
		 (getKeeperPosition (cdr s) (+ row 1))
		 );end if
	       );end let
	 );end t
	);end cond
  );end defun

;
; cleanUpList (l)
; returns l with any NIL element removed.
; For example, if l is '(1 2 NIL 3 NIL), returns '(1 2 3).
;
(defun cleanUpList (L)
  (cond ((null L) nil)
	(t (let ((cur (car L))
		 (res (cleanUpList (cdr L)))
		 )
	     (if cur 
		 (cons cur res)
		  res
		 )
	     );end let
	   );end t
	);end cond
  );end 

;; Custom helper functions
;
; numBoxes (row)
; helper function for goal-test and h1
; @row a single row of a state (list of lists of numbers)
; @return number of misplaced boxes (not on goal square)
(defun numBoxes (row)
    (count-if #'isBox row)
  );end defun

;
; add-star (val)
; @param val value of a square (e.g. blank, wall, star, etc.)
; @return integer val+star (stars get no change)
(defun add-star (val)
  (cond
    ((isBlank val) star)
    ((isWall val) wall)
    ((isBox val) boxStar)
    ((isKeeper val) keeperStar)
    ((isStar val) star)
    ((isBoxStar val) boxStar)
    ((isKeeperStar val) keeperStar)
    );end cond
  );end defun

;
; minus-star (val)
; @param val value of a square (e.g. blank, wall, star, etc.)
; @return integer from taking star away from val
(defun minus-star (val)
  (cond
    ((isBlank val) blank)
    ((isWall val) wall)
    ((isBox val) box)
    ((isKeeper val) keeper)
    ((isStar val) blank)
    ((isBoxStar val) box)
    ((isKeeperStar val) keeper)
    );end cond
  );end defun


; EXERCISE: Modify this function to return true (t)
; if and only if s is a goal state of a Sokoban game.
; (no box is on a non-goal square)
;
; Currently, it always returns NIL. If A* is called with
; this function as the goal testing function, A* will never
; terminate until the whole search space is exhausted.
;
; Logic: return t if there are any 2's (non-goal boxes)
;
(defun goal-test (s)
  (cond
    ((null s) t)
    ((> (numBoxes (car s)) 0) nil)
    (t (goal-test (cdr s)))
    );end cond
  );end defun



;
; valueAt (s x y)
; equivalent to get-square in spec
; @param s current state
; @param x 0-indexed x-coordinate (row num)
; @param y 0-indexed y-coordinate (col num)
; @return the value at s[x][y] if exists, else nil
; logic: cut the first x rows => first row is s[x]
; then s[x][y]
(defun valueAt (s x y)
  (cond 
    ((or (not (numberp x)) (not (numberp y)) (< x 0) (< y 0)
      (>= x (length s)) (>= y (length (car s)))) nil)
    (t (nth y (car (nthcdr x s))))
    );end cond
  );end defun

;
; set-to (s x y val)
; equivalent to set-square in spec 
; @param s the current state
; @param x x-position
; @param y y-position
; @param val value to set
; @return state after setting row x col y of s to val
; logic: isolate row s[x], then isolate to cell s[x][y]
; replace the value of s[x][y], appending the columns then rows back
(defun set-to (s x y val)
  (append
    ; rows s[0] to s[x-1]
    (butlast s (- (length s) x))
    ; row s[x]: (nth (- x 1) s)
    (list (append
      ; s[x][0] to s[x][y-1]
      (butlast (nth x s) (- (length (nth x s)) y))
      ; the value to replace
      (list val)
      ; s[x][y+1] to s[x][length-1]
      (nthcdr (+ y 1) (nth x s)))) 
    ; rows s[x+1] to s[length-1]
    (nthcdr (+ x 1) s)
    );end append
  );end defun


;
; move-to (s from-x from-y to-x to-y)
; @param s the current state
; @param from-x x-position of current object
; @param from-y y-position of current object
; @param to-x desired x-position of current object
; @param to-y desired y-position of current object
; @return state after moving object from s[from-x][from-y] to s[to-x][to-y]
; if move is legal, else nil
; logic: check legality of move (out of bounds, hits wall, etc.)
; then move objects that result in only 1 move (e.g. box to blank, keeper to blank)
; then do moves that result in 2 moves (keeper to box moves both the box and keeper)
(defun move-to (s from-x from-y to-x to-y)
  (let* ((from-val (valueAt s from-x from-y))
          (to-val (valueAt s to-x to-y)))
    (cond
      ; remove null cases and
      ; remove things that can't move or be moved into
      ((or (null s) (null from-val) (null to-val)
        (isWall from-val) (isBlank from-val) (isStar from-val)
        (isWall to-val) (isKeeper to-val) (isKeeperStar to-val)) nil)
      ; from and to are the same
      ((and (= from-x to-x) (= from-y to-y)) s)

      ; Part 1: only 1 object moves
      ; to a blank
      ((isBlank to-val)
        (cond 
          ; simple swap if from-val is keeper or box
          ((or (isBox from-val) (isKeeper from-val))
            (set-to (set-to s to-x to-y from-val) from-x from-y blank))
          ; from-val is keeperstar or boxstar
          ((or (isBoxStar from-val) (isKeeperStar from-val))
            (set-to (set-to s to-x to-y (minus-star from-val)) from-x from-y star))
          (t nil)))
      ; to a star (goal)
      ((isStar to-val)
        (cond 
          ; from-val is a keeper or box
          ((or (isKeeper from-val) (isBox from-val))
            (set-to (set-to s to-x to-y (add-star from-val)) from-x from-y blank))
          ; simple swap if both have stars
          ((or (isBoxStar from-val) (isKeeperStar from-val))
            (set-to (set-to s to-x to-y from-val) from-x from-y star))
          (t nil)))
      ; a box cannot move another box
      ((and (or (isBox from-val) (isBoxStar from-val))
            (or (isBox to-val) (isBoxStar to-val))) nil)
      
      ; Part 2: 2 objects move (keeper was from-val, trying to move a box) 
      ((or (isKeeper from-val) (isKeeperStar from-val))
        ; determine direction
        (let* ((box-to-x (+ (- to-x from-x) to-x))
              (box-to-y (+ (- to-y from-y) to-y)))
            ; try to move the box first, then the keeper
            (move-to (move-to s to-x to-y box-to-x box-to-y) from-x from-y to-x to-y)
          );end let
        )
      (t nil) ; every case should be covered
      );end cond
    );end let
  );end defun


;
; try-move (s dir)
; helper function for next-states
; @param s the current state
; @return the state after moving (if the move is possible, else nil)
(defun try-move (s dir)
  (let* ((pos (getKeeperPosition s 0)) (x (cadr pos)) (y (car pos)))
    (cond
      ((null s) nil)
      ((equal dir 'up) (move-to s x y x (- y 1)))
      ((equal dir 'down) (move-to s x y x (+ y 1)))
      ((equal dir 'left) (move-to s x y (- x 1) y))
      ((equal dir 'right) (move-to s x y (+ x 1) y))
      (t nil); bad input 
      );end cond
    );end let
  );end defun



; EXERCISE: Modify this function to return the list of 
; sucessor states of s.
;
; This is the top-level next-states (successor) function.
; Some skeleton code is provided below.
; You may delete them totally, depending on your approach.
; 
; If you want to use it, you will need to set 'result' to be 
; the set of states after moving the keeper in each of the 4 directions.
; A pseudo-code for this is:
; 
; ...
; (result (list (try-move s UP) (try-move s DOWN) (try-move s LEFT) (try-move s RIGHT)))
; ...
; 
; You will need to define the function try-move and decide how to represent UP,DOWN,LEFT,RIGHT.
; Any NIL result returned from try-move can be removed by cleanUpList.
; 
;
(defun next-states (s)
  (cleanUpList
     (list (try-move s 'up) (try-move s 'down)
         (try-move s 'left) (try-move s 'right)))
  );end defun

; EXERCISE: Modify this function to compute the trivial 
; admissible heuristic.
; logic: return 0
(defun h0 (s)
  0)

; EXERCISE: Modify this function to compute the 
; number of misplaced boxes in s.
; Admissible heuristic: yes; if there are n misplaced boxes,
;   you must make at least n moves to put those boxes in goal states 
; logic: add up the number of non-goal boxes for each row 
(defun h1 (s)
  (cond
    ((null s) 0)
    (t (+ (numBoxes (car s)) (h1 (cdr s))))
    );end cond
  );end defun


;
; manhattan-dist (from-x from-y to-x to-y)
; @param from-x integer x position of from object
; @param from-y integer y position of from object
; @param to-x integer x position of to object
; @param to-y integer y position of to object
; @return integer, manhattan distance from (from-x, from-y) to (to-x, to-y)
; (i.e. can only move up/down/left/right)
(defun manhattan-dist (from-x from-y to-x to-y)
  (+ 
    (if (> to-x from-x) (- to-x from-x) (- from-x to-x))
    (if (> to-y from-y) (- to-y from-y) (- from-y to-y))
    );end + 
  );end defun

;
; getStarPositionsInRow (row x y)
; helper function of getStarPositions
; @param row a row of numbers
; @param x the current x position
; @param y the current y position
; @return a list of box positions for the given row
(defun getStarPositionsInRow (row x y)
  (if (null row) nil
    (if (isStar (car row))
      (append (list (list x y)) (getStarPositionsInRow (cdr row) x (+ y 1)))
      (getStarPositionsInRow (cdr row) x (+ y 1))
      );end if
    );end if
  );end defun

;
; getStarPositions (s firstRow)
; @param s the current state
; @param firstRow the first row to consider
; @return a list of positions of every misplaced box
; (e.g. '((1 2) (3 4))). You should call getStarPositions (s 0)
(defun getStarPositions (s firstRow)
  (if (null s) nil
    (let* ((result (getStarPositionsInRow (car s) firstRow 0)))
      (append result (getStarPositions (cdr s) (+ firstRow 1)))
      );end let
    );end if
  );end defun


;
; getBoxPositionsInRow (row x y)
; helper function of getBoxPositions
; @param row a row of numbers
; @param x the current x position
; @param y the current y position
; @return a list of box positions for the given row
(defun getBoxPositionsInRow (row x y)
  (if (null row) nil
    (if (isBox (car row))
      (append (list (list x y)) (getBoxPositionsInRow (cdr row) x (+ y 1)))
      (getBoxPositionsInRow (cdr row) x (+ y 1))
      );end if
    );end if
  );end defun

;
; getBoxPositions (s firstRow)
; @param s the current state
; @param firstRow the first row to consider
; @return a list of positions of every misplaced box
; (e.g. '((1 2) (3 4))). You should call getBoxPositions (s 0)
(defun getBoxPositions (s firstRow)
  (if (null s) nil
    (let* ((result (getBoxPositionsInRow (car s) firstRow 0)))
      (append result (getBoxPositions (cdr s) (+ firstRow 1)))
      );end let
    );end if
  );end defun


; 
; closest-manhattan-dist (pos compareList)
; @param pos home position (e.g. (1 2))
; @param compareList list of positions to compare to
; @return minimum manhattan distance between pos and the positions in compareList
; if compareList is null, returns nil
(defun closest-manhattan-dist (pos compareList)
  (if (or (null pos) (null compareList)) nil
    (let* ((min-of-rest (closest-manhattan-dist pos (cdr compareList))))
      (if (null min-of-rest)
        (manhattan-dist (car pos) (cadr pos) (caar compareList) (cadar compareList))
        (min (manhattan-dist (car pos) (cadr pos) (caar compareList) (cadar compareList)) min-of-rest)
        );end if
      );end let
    );end if
  );end defun


; 
; total-manhattan-dist (boxPositions starPositions)
; helper function for hUID
; @param boxPositions position of box, each is a 2-size list
; @param starPositions list of positions of stars
; @return total manhattan distance
; logic: for each position in boxPositions, find the closest goal and the
; distance to it. Add up distances for each position
(defun total-manhattan-dist (boxPositions starPositions)
  (if (or (null boxPositions) (null starPositions)) 0
    (let* (
      (first-dist (closest-manhattan-dist (car boxPositions) starPositions))
      (total-of-rest (total-manhattan-dist (cdr boxPositions) starPositions)))
        (+
          (if (null first-dist) 0 first-dist)
          (if (null total-of-rest) 0 total-of-rest)
        )
      );end let
    );end if
  );end defun

; 
; mbc-helper (s boxPositions)
; @param s state
; @param boxPositions a list of positions of misplaced boxes
(defun mbc-helper (s boxPositions)
  (if (null boxPositions) nil
    (let* ((x (caar boxPositions)) (y (cadar boxPositions))
      (up (valueAt s x (- y 1))) (down (valueAt s x (+ y 1)))
      (left (valueAt s (- x 1) y)) (right (valueAt s (+ x 1) y)))
      (cond 
        ((or 
          ; up/left
          (and (or (null up) (isWall up)) (or (null left) (isWall left)))
          ; up/right
          (and (or (null up) (isWall up)) (or (null right) (isWall right)))
          ; down/left
          (and (or (null down) (isWall down)) (or (null left) (isWall left)))
          ; down/right
          (and (or (null down) (isWall down)) (or (null right) (isWall right)))
          ) t)
        (t (mbc-helper s (cdr boxPositions)))
        );end cond
      );end let
    );end if
  );end defun

; 
; misplaced-box-in-corner (s)
; @param s current state
; @return t if there is a box in a corner
(defun misplaced-box-in-corner (s)
  (if (null s) nil
   (let* ((boxPoses (getBoxPositions s 0)))
     (mbc-helper s boxPoses)
     );end let
    );end if
  );end defun

; 
; isImpossibleCase (s)
; @param s state
; @return t if s satisfies any impossible case, else nil
(defun isImpossibleCase (s)
  (cond ((or 
    ; impossible cases go here
    (misplaced-box-in-corner s)
    ;TODO: (misplaced-box-along-wall s)
    ;TODO: 2x2 or more rectangles of boxes with at least one misplaced (cannot be moved)

    ) t)
    ; no impossible case
    (t nil)
    );end cond
  );end defun

; misplaced box in a corner (1 up/down, 1 left/right) - you can't move it
; misplaced box along a line of wall with no goals (open or closed)
; 2x2 or more rectangle of boxes and at least one is misplaced (cannot be moved)


; EXERCISE: Change the name of this function to h<UID> where
; <UID> is your actual student ID number. Then, modify this 
; function to compute an admissible heuristic value of s. 
; 
; This function will be entered in the competition.
; Objective: make A* solve problems as fast as possible.
; The Lisp 'time' function can be used to measure the 
; running time of a function call.
;
; logic: use manhattan distance between each misplaced box and its closest star
; add them all up to make a heuristic
(defun h804621520 (s)
  (if (isImpossibleCase s) 2000
    (let* ((boxPositions (getBoxPositions s 0))
          (starPositions (getStarPositions s 0)))
        (total-manhattan-dist boxPositions starPositions)
      ); end let
    );end if
  );end defun



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|
 | Some predefined problems.
 | Each problem can be visualized by calling (printstate <problem>). For example, (printstate p1).
 | Problems are ordered roughly by their difficulties.
 | For most problems, we also privide 2 additional number per problem:
 |    1) # of nodes expanded by A* using our next-states and h0 heuristic.
 |    2) the depth of the optimal solution.
 | These numbers are located at the comments of the problems. For example, the first problem below 
 | was solved by 80 nodes expansion of A* and its optimal solution depth is 7.
 | 
 | Your implementation may not result in the same number of nodes expanded, but it should probably
 | give something in the same ballpark. As for the solution depth, any admissible heuristic must 
 | make A* return an optimal solution. So, the depths of the optimal solutions provided could be used
 | for checking whether your heuristic is admissible.
 |
 | Warning: some problems toward the end are quite hard and could be impossible to solve without a good heuristic!
 | 
 |#

;(80,7)
(setq p1 '((1 1 1 1 1 1)
	   (1 0 3 0 0 1)
	   (1 0 2 0 0 1)
	   (1 1 0 1 1 1)
	   (1 0 0 0 0 1)
	   (1 0 0 0 4 1)
	   (1 1 1 1 1 1)))

;(110,10)
(setq p2 '((1 1 1 1 1 1 1)
	   (1 0 0 0 0 0 1) 
	   (1 0 0 0 0 0 1) 
	   (1 0 0 2 1 4 1) 
	   (1 3 0 0 1 0 1)
	   (1 1 1 1 1 1 1)))

;(211,12)
(setq p3 '((1 1 1 1 1 1 1 1 1)
	   (1 0 0 0 1 0 0 0 1)
	   (1 0 0 0 2 0 3 4 1)
	   (1 0 0 0 1 0 0 0 1)
	   (1 0 0 0 1 0 0 0 1)
	   (1 1 1 1 1 1 1 1 1)))

;(300,13)
(setq p4 '((1 1 1 1 1 1 1)
	   (0 0 0 0 0 1 4)
	   (0 0 0 0 0 0 0)
	   (0 0 1 1 1 0 0)
	   (0 0 1 0 0 0 0)
	   (0 2 1 0 0 0 0)
	   (0 3 1 0 0 0 0)))

;(551,10)
(setq p5 '((1 1 1 1 1 1)
	   (1 1 0 0 1 1)
	   (1 0 0 0 0 1)
	   (1 4 2 2 4 1)
	   (1 0 0 0 0 1)
	   (1 1 3 1 1 1)
	   (1 1 1 1 1 1)))

;(722,12)
(setq p6 '((1 1 1 1 1 1 1 1)
	   (1 0 0 0 0 0 4 1)
	   (1 0 0 0 2 2 3 1)
	   (1 0 0 1 0 0 4 1)
	   (1 1 1 1 1 1 1 1)))

;(1738,50)
(setq p7 '((1 1 1 1 1 1 1 1 1 1)
	   (0 0 1 1 1 1 0 0 0 3)
	   (0 0 0 0 0 1 0 0 0 0)
	   (0 0 0 0 0 1 0 0 1 0)
	   (0 0 1 0 0 1 0 0 1 0)
	   (0 2 1 0 0 0 0 0 1 0)
	   (0 0 1 0 0 0 0 0 1 4)))

;(1763,22)
(setq p8 '((1 1 1 1 1 1)
	   (1 4 0 0 4 1)
	   (1 0 2 2 0 1)
	   (1 2 0 1 0 1)
	   (1 3 0 0 4 1)
	   (1 1 1 1 1 1)))

;(1806,41)
(setq p9 '((1 1 1 1 1 1 1 1 1) 
	   (1 1 1 0 0 1 1 1 1) 
	   (1 0 0 0 0 0 2 0 1) 
	   (1 0 1 0 0 1 2 0 1) 
	   (1 0 4 0 4 1 3 0 1) 
	   (1 1 1 1 1 1 1 1 1)))

;(10082,51)
(setq p10 '((1 1 1 1 1 0 0)
	    (1 0 0 0 1 1 0)
	    (1 3 2 0 0 1 1)
	    (1 1 0 2 0 0 1)
	    (0 1 1 0 2 0 1)
	    (0 0 1 1 0 0 1)
	    (0 0 0 1 1 4 1)
	    (0 0 0 0 1 4 1)
	    (0 0 0 0 1 4 1)
	    (0 0 0 0 1 1 1)))

;(16517,48)
(setq p11 '((1 1 1 1 1 1 1)
	    (1 4 0 0 0 4 1)
	    (1 0 2 2 1 0 1)
	    (1 0 2 0 1 3 1)
	    (1 1 2 0 1 0 1)
	    (1 4 0 0 4 0 1)
	    (1 1 1 1 1 1 1)))

;(22035,38)
(setq p12 '((0 0 0 0 1 1 1 1 1 0 0 0)
	    (1 1 1 1 1 0 0 0 1 1 1 1)
	    (1 0 0 0 2 0 0 0 0 0 0 1)
	    (1 3 0 0 0 0 0 0 0 0 0 1)
	    (1 0 0 0 2 1 1 1 0 0 0 1)
	    (1 0 0 0 0 1 0 1 4 0 4 1)
	    (1 1 1 1 1 1 0 1 1 1 1 1)))

;(26905,28)
(setq p13 '((1 1 1 1 1 1 1 1 1 1)
	    (1 4 0 0 0 0 0 2 0 1)
	    (1 0 2 0 0 0 0 0 4 1)
	    (1 0 3 0 0 0 0 0 2 1)
	    (1 0 0 0 0 0 0 0 0 1)
	    (1 0 0 0 0 0 0 0 4 1)
	    (1 1 1 1 1 1 1 1 1 1)))

;(41715,53)
(setq p14 '((0 0 1 0 0 0 0)
	    (0 2 1 4 0 0 0)
	    (0 2 0 4 0 0 0)	   
	    (3 2 1 1 1 0 0)
	    (0 0 1 4 0 0 0)))

;(48695,44)
(setq p15 '((1 1 1 1 1 1 1)
	    (1 0 0 0 0 0 1)
	    (1 0 0 2 2 0 1)
	    (1 0 2 0 2 3 1)
	    (1 4 4 1 1 1 1)
	    (1 4 4 1 0 0 0)
	    (1 1 1 1 0 0 0)
	    ))

;(91344,111)
(setq p16 '((1 1 1 1 1 0 0 0)
	    (1 0 0 0 1 0 0 0)
	    (1 2 1 0 1 1 1 1)
	    (1 4 0 0 0 0 0 1)
	    (1 0 0 5 0 5 0 1)
	    (1 0 5 0 1 0 1 1)
	    (1 1 1 0 3 0 1 0)
	    (0 0 1 1 1 1 1 0)))

;(3301278,76)
(setq p17 '((1 1 1 1 1 1 1 1 1 1)
	    (1 3 0 0 1 0 0 0 4 1)
	    (1 0 2 0 2 0 0 4 4 1)
	    (1 0 2 2 2 1 1 4 4 1)
	    (1 0 0 0 0 1 1 4 4 1)
	    (1 1 1 1 1 1 0 0 0 0)))

;(??,25)
(setq p18 '((0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0)
	    (0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0)
	    (1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1)
	    (0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0)
	    (0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0)
	    (0 0 0 0 0 0 0 0 3 0 0 0 0 0 0 0)
	    (0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0)
	    (0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0)
	    (1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1)
	    (0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0)
	    (0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0)
	    (0 0 0 0 1 0 0 0 0 0 4 1 0 0 0 0)
	    (0 0 0 0 1 0 2 0 0 0 0 1 0 0 0 0)	    
	    (0 0 0 0 1 0 2 0 0 0 4 1 0 0 0 0)
	    ))
;(??,21)
(setq p19 '((0 0 0 1 0 0 0 0 1 0 0 0)
	    (0 0 0 1 0 0 0 0 1 0 0 0)
	    (0 0 0 1 0 0 0 0 1 0 0 0)
	    (1 1 1 1 0 0 0 0 1 1 1 1)
	    (0 0 0 0 1 0 0 1 0 0 0 0)
	    (0 0 0 0 0 0 3 0 0 0 2 0)
	    (0 0 0 0 1 0 0 1 0 0 0 4)
	    (1 1 1 1 0 0 0 0 1 1 1 1)
	    (0 0 0 1 0 0 0 0 1 0 0 0)
	    (0 0 0 1 0 0 0 0 1 0 0 0)
	    (0 0 0 1 0 2 0 4 1 0 0 0)))

;(??,??)
(setq p20 '((0 0 0 1 1 1 1 0 0)
	    (1 1 1 1 0 0 1 1 0)
	    (1 0 0 0 2 0 0 1 0)
	    (1 0 0 5 5 5 0 1 0)
	    (1 0 0 4 0 4 0 1 1)
	    (1 1 0 5 0 5 0 0 1)
	    (0 1 1 5 5 5 0 0 1)
	    (0 0 1 0 2 0 1 1 1)
	    (0 0 1 0 3 0 1 0 0)
	    (0 0 1 1 1 1 1 0 0)))

;(??,??)
(setq p21 '((0 0 1 1 1 1 1 1 1 0)
	    (1 1 1 0 0 1 1 1 1 0)
	    (1 0 0 2 0 0 0 1 1 0)
	    (1 3 2 0 2 0 0 0 1 0)
	    (1 1 0 2 0 2 0 0 1 0)
	    (0 1 1 0 2 0 2 0 1 0)
	    (0 0 1 1 0 2 0 0 1 0)
	    (0 0 0 1 1 1 1 0 1 0)
	    (0 0 0 0 1 4 1 0 0 1)
	    (0 0 0 0 1 4 4 4 0 1)
	    (0 0 0 0 1 0 1 4 0 1)
	    (0 0 0 0 1 4 4 4 0 1)
	    (0 0 0 0 1 1 1 1 1 1)))

;(??,??)
(setq p22 '((0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0)
	    (0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0)
	    (0 0 0 0 1 2 0 0 1 0 0 0 0 0 0 0 0 0 0)
	    (0 0 1 1 1 0 0 2 1 1 0 0 0 0 0 0 0 0 0)
	    (0 0 1 0 0 2 0 2 0 1 0 0 0 0 0 0 0 0 0)
	    (1 1 1 0 1 0 1 1 0 1 0 0 0 1 1 1 1 1 1)
	    (1 0 0 0 1 0 1 1 0 1 1 1 1 1 0 0 4 4 1)
	    (1 0 2 0 0 2 0 0 0 0 0 0 0 0 0 0 4 4 1)
	    (1 1 1 1 1 0 1 1 1 0 1 3 1 1 0 0 4 4 1)
	    (0 0 0 0 1 0 0 0 0 0 1 1 1 1 1 1 1 1 1)
	    (0 0 0 0 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|
 | Utility functions for printing states and moves.
 | You do not need to understand any of the functions below this point.
 |#

;
; Helper function of prettyMoves
; from s1 --> s2
;
(defun detectDiff (s1 s2)
  (let* ((k1 (getKeeperPosition s1 0))
	 (k2 (getKeeperPosition s2 0))
	 (deltaX (- (car k2) (car k1)))
	 (deltaY (- (cadr k2) (cadr k1)))
	 )
    (cond ((= deltaX 0) (if (> deltaY 0) 'DOWN 'UP))
	  (t (if (> deltaX 0) 'RIGHT 'LEFT))
	  );end cond
    );end let
  );end defun

;
; Translates a list of states into a list of moves.
; Usage: (prettyMoves (a* <problem> #'goal-test #'next-states #'heuristic))
;
(defun prettyMoves (m)
  (cond ((null m) nil)
	((= 1 (length m)) (list 'END))
	(t (cons (detectDiff (car m) (cadr m)) (prettyMoves (cdr m))))
	);end cond
  );

;
; Print the content of the square to stdout.
;
(defun printSquare (s)
  (cond ((= s blank) (format t " "))
	((= s wall) (format t "#"))
	((= s box) (format t "$"))
	((= s keeper) (format t "@"))
	((= s star) (format t "."))
	((= s boxstar) (format t "*"))
	((= s keeperstar) (format t "+"))
	(t (format t "|"))
	);end cond
  )

;
; Print a row
;
(defun printRow (r)
  (dolist (cur r)
    (printSquare cur)    
    )
  );

;
; Print a state
;
(defun printState (s)
  (progn    
    (dolist (cur s)
      (printRow cur)
      (format t "~%")
      )
    );end progn
  )

;
; Print a list of states with delay.
;
(defun printStates (sl delay)
  (dolist (cur sl)
    (printState cur)
    (sleep delay)
    );end dolist
  );end defun

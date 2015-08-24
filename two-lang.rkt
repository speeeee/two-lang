#lang racket/base
(require racket/list)

(struct la (ins cont) #:transparent)
(struct fn (name ins) #:transparent)
(struct app (name tar) #:transparent)
; `fn' is the lowest level. always confirmed simplest form.
; these functions cannot be partially applied at top-level.
(struct exp (h t) #:transparent) ; LISP-style s-expression. (lambda . args-list)
(struct apl (h t) #:transparent)
(struct v (val type) #:transparent)
(define (sym? s) (and (v? s) (equal? (v? s) "Sym")))
(define (ins lf) (if (la? lf) (length (la-ins lf)) (fn-ins lf)))

(define (push stk elt) (append stk (list elt)))
(define (pop stk) (car (reverse stk)))
(define (ret-pop stk) (reverse (cdr (reverse stk))))
(define (strcar str) (car (string->list str)))
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))

(define funs (list (list "Fun" "add" 2)))
(define ruls '())

(define test0 "TXT \"ffffff\"")
(define test1 "(a b) = (1 2)")
(define test2 "(a $a) = (b $a)")
(define test3 "(d (($a Int))) = (d $a)") ; d 1

; surrounds string with quotation marks
(define (quoti lst) (append (list #\") (push lst #\")))

; a = (l . r)
; b = (rl . rr)

; get-vars: get list of '$'-prefixed values and binding them to their counterparts.
(define (get-vars a b) (foldl (λ (x y vs) (begin 
  (cond [(and (list? x) (list? y)) (append vs (get-vars x y))]
        [(equal? (strcar y) #\$) (push vs (list y x))] [else vs]))) '() a b))

; equiv?: same as equal?, except all symbols prefixed by '$' are ignored.
(define (equiv? a b) (and (= (length a) (length b))
  (andmap (λ (x y) (cond [(and (list? x) (list? y)) (equiv? x y)] [(or (equal? x y) (equal? (strcar y) #\$)) #t]
                         [else #f])) a b)))

; a = (l . r)
; b = ((rl . rr) (rl' . rr'))

; rewrite: rewrites the left side of a rule into the right side.
(define (rewrite a b) (let ([vars (get-vars a (car b))]) (rw (second b) vars)))
(define (rw b vs)
  (map (λ (x) (cond [(list? x) (rw x vs)] [(equal? (strcar x) #\$) (second (find-eq x car vs))] 
                    [else x])) b))

(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'str) (if (equal? s #\") (push (push (ret-pop (second n)) (quoti (pop (second n)))) '()) 
                                   (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\{ #\} #\[ #\] #\: #\')) (append n (list (list s)) (list '()))]
        [(equal? s #\space) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (equal? elt ")"))) (push n elt)
      (let* ([c (case elt [("}") "{"] [("]") "["] [(")") "("] [else '()])]
                          [expr (λ (x) (not (equal? x c)))])
        (push (ret-pop (reverse (dropf (reverse n) expr))) (reverse (takef (reverse n) expr)))))) '() lst))

(define (lex s)
  (cond [(member s (list "(" ")" "{" "}" "[" "]")) s]
        [(member s (map second funs)) (find-eq s second funs)] 
        [(char-numeric? (strcar s)) (list s "Int")] [(equal? (strcar s) #\") (list s "String")] 
        [else s]))

(define (parse-expr lst) (foldr (λ (lx r)
  (let ([l (if (list? lx) (parse-expr lx) lx)])
    (cond [(empty? r) (cons l r)] [(equal? l "=") (list "Infix=" r)]
          [(and (list? r) (equal? (car r) "Infix=")) 
           (begin (set! ruls (push ruls (list l (second r)))) '())]
          [(and (equal? l "TXT") (equal? (cadar r) "String")) (fprintf (current-output-port) "~a" (caar r))]
          [(ormap (λ (x) (equiv? (list l r) (car x))) ruls) (rewrite (list l r) (findf (λ (x) (equiv? (list l r) (car x))) ruls))]
          [(list? r) (cons l r)]
          [else (printf "ERROR: Combination, `~a` . `~a`, does not exist.~n"
                        l r)]))) '() lst))

(define (parse l) (parse-expr (check-parens (map lex (string-split-spec l)))))
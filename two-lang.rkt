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

(define funs (list (fn "=" 2) (fn "add" 2)))

(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'str) (if (equal? s #\") (push (second n) '()) (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\{ #\} #\[ #\] #\: #\')) (append n (list (list s)) (list '()))]
        [(equal? s #\space) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (equal? elt ")"))) (push n elt)
      (let* ([c (case elt [("}") "{"] [("]") "["] [(")") "("] [else '()])]
                          [expr (λ (x) (not (equal? x c)))])
        (push (ret-pop (reverse (dropf (reverse n) expr))) (reverse (takef (reverse n) expr)))))) '() lst))

(define (lex s)
  (cond [(member s (list "(" ")" "{" "}" "[" "]" ":" "'")) s]
        [(member s (map fn-name funs)) (find-eq s fn-name funs)] 
        ;[(char-numeric? (strcar s)) (v s "Int")] [(equal? (strcar s) #\") (v s "String")] 
        [else s]))

(define (parse-expr lst) (foldr (λ (l r)
  (cond [(list? r) (cons l r)]
        [else (printf "ERROR: Combination, `~a` . `~a`, does not exist.~n"
                      l r)])) '() lst))

(define (parse l) (map lex (check-parens (string-split-spec l))))
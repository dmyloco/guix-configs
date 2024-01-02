(define-module (disko utils)
  #:export (MiB
	    GiB
	    percentage))

;; (define (MiB size) (expt 2 20))
;; (define (GiB size) (* (MiB size) 1024))

(define (MiB size) (format #f "~aMiB" size))
(define (GiB size) (format #f "~aGiB" size))

(define (percentage size)
  (if (and (<= size 100)
	   (> size 0))
      (format #f "~a%" size)
      (error (format #f "incorrect percentage: ~a%" size))))

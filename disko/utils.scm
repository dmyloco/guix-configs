(define-module (disko utils)
  #:export (MiB
	    GiB
	    percentage))

(define (MiB size) (expt 2 20))
(define (GiB size) (* (MiB size) 1024))

(define (percentage size)
  (if (and (< size 100)
	   (> size 0))
      size
      (error (format #f "incorrect percentage: ~a%" size))))

(define-module (disko partitioning)
  #:use-module (guix records)
  #:export (disk-partition
	    disk-partition?
	    disk-partition-start
	    disk-partition-end
	    part-disk))

(define (gnu-parted disk script)
  (display (string-join script))
  (newline))

(define-record-type* <disk-partition>
  disk-partition
  make-disk-partition
  disk-partition?
  (name disk-partition-name (default ""))
  (start disk-partition-start)
  (end disk-partition-end))

(define* (part-disk disk partitions
		    #:key (label "gpt"))
  "Part disk using GNU Parted."
  (gnu-parted disk (list "mklabel" label))
  (for-each
   (lambda (partition)
     (gnu-parted
      disk
      (list "mkpart"
	    (if (string-null? (disk-partition-name partition))
		"\"\"" (disk-partition-name partition))
	    (disk-partition-start partition)
	    (disk-partition-end partition))))
   partitions))

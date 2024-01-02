(define-module (disko runner)
  #:use-module (disko device)
  #:use-module (disko partitioning)
  #:export (run-disko))

(define (get-partition-start-end partition)
  (cond ((vfat-partition? partition)
	 (list (vfat-partition-start partition) (vfat-partition-end partition)))
	((btrfs-partition? partition)
	 (list (btrfs-partition-start partition) (btrfs-partition-end partition)))))

(define (run-disko devices)
  (for-each
   (lambda (i device)
     (display (format #f "Setup device: ~a ..."
		      (disko-device-file device)))
     (newline)
     (part-disk (disko-device-file device)
		(disko-device-partitions device)))
   (iota (length devices)) devices))

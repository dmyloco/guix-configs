(define-module (disko partitions vfat)
  #:use-module (guix records)
  #:export (vfat-partition
	    vfat-partition?
	    vfat-partition-start
	    vfat-partition-end
	    vfat-partition-mount-point

	    make-vfat-partition))

(define-record-type* <vfat-partition>
  vfat-partition
  %vfat-partition
  vfat-partition?
  (start vfat-partition-start)
  (end vfat-partition-end)
  (mount-point vfat-partition-mount-point))

(define (make-vfat-partition file partition)
  (display (string-join
	    (list "mkfs.vfat" file)))
  (newline))

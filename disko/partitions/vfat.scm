(define-module (disko partitions vfat)
  #:use-module (gnu system file-systems)
  #:use-module (guix records)
  #:export (vfat-partition
	    vfat-partition?
	    vfat-partition-start
	    vfat-partition-end
	    vfat-partition-mount-point

	    make-vfat-partition
	    vfat-partition->file-systems))

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

(define (vfat-partition->file-systems disk partition)
  (list (file-system
	 (mount-point (vfat-partition-mount-point partition))
	 (type "vfat")
	 (device disk))))

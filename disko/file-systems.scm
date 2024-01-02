(define-module (disko file-systems)
  #:use-module (disko partitions vfat)
  #:use-module (disko partitions btrfs)
  #:use-module (disko device)
  #:use-module (srfi srfi-1)
  #:export (make-file-systems
	    devices->file-systems))

(define (make-fs file partition)
  (cond ((vfat-partition? partition)
	 (make-vfat-partition file partition))
	((btrfs-partition? partition)
	 (make-btrfs-partition file partition))
	(else
	 (error (format #f "Undefined partition type: ~a" partition)))))

(define (make-file-systems device)
  (let* ((file (disko-device-file device))
	 (make-part-name (lambda (i)
			   (cond ((string-prefix? "nvme" (basename file))
				  (format
				   #f "~ap~a" file i))
				 (else
				  (error (format #f "Unresolved device: ~a" file))))))
	 (partitions (map make-part-name (iota (length (disko-device-partitions device)) 1))))
    (for-each
     (lambda (file partition)
       (make-fs file partition))
     partitions (disko-device-partitions device))
    ))

(define (partitions->file-systems disk partitions)
  (append-map
   (lambda (partition)
     (cond ((vfat-partition? partition)
	    (vfat-partition->file-systems disk partition))
	   ((btrfs-partition? partition)
	    (btrfs-partition->file-systems disk partition))))
   partitions))

(define (devices->file-systems devices)
  (append-map
   (lambda (device)
     (partitions->file-systems
      (disko-device-file device)
      (disko-device-partitions device)))
   devices))

(define-module (disko partitioning)
  #:use-module (disko partitions vfat)
  #:use-module (disko partitions btrfs)
  #:use-module (guix records)
  #:export (disk-partition
	    disk-partition?
	    disk-partition-start
	    disk-partition-end
	    part-disk))

(define (gnu-parted disk script)
  (display "parted --script --align=optimal \"")
  (display disk)
  (display "\" -- ")
  (display (string-join script))
  (newline))

(define-record-type* <disk-partition>
  disk-partition
  make-disk-partition
  disk-partition?
  (name disk-partition-name (default ""))
  (start disk-partition-start)
  (end disk-partition-end))

(define (get-disk-partition partition)
  (cond ((vfat-partition? partition)
	 (disk-partition
	  (start (vfat-partition-start partition))
	  (end (vfat-partition-end partition))))
	((btrfs-partition? partition)
	 (disk-partition
	  (start (btrfs-partition-start partition))
	  (end (btrfs-partition-end partition))))
	(else
	 (error (format #f "Unsupported partition type: ~a" partition)))))

(define* (part-disk disk partitions
		    #:key (label "gpt"))
  "Part disk using GNU Parted."
  (let ((partitions (map get-disk-partition partitions)))
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
     partitions)))

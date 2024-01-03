(define-module (disko partitions btrfs)
  #:use-module (gnu system file-systems)
  #:use-module (guix records)
  #:use-module (disko utils)
  #:use-module (ice-9 match)
  #:export (btrfs-partition
	    btrfs-partition?
	    btrfs-partition-start
	    btrfs-partition-end
	    btrfs-partition-mount-point
	    btrfs-partition-extra-args
	    btrfs-partition-subvolumes
	    btrfs-partition-swapfiles

	    btrfs-subvolume
	    btrfs-subvolume?
	    btrfs-subvolume-path
	    btrfs-subvolume-mount-point
	    btrfs-subvolume-options

	    btrfs-swapfile
	    btrfs-swapfile?
	    btrfs-swapfile-path
	    btrfs-swapfile-size

	    make-btrfs-partition
	    btrfs-partition->file-systems))

(define-record-type* <btrfs-partition>
  btrfs-partition
  %btrfs-partition
  btrfs-partition?
  (start btrfs-partition-start)
  (end btrfs-partition-end)
  (mount-point btrfs-partition-mount-point)
  (extra-args btrfs-partition-extra-args)
  (subvolumes btrfs-partition-subvolumes)
  (swapfiles btrfs-partition-swapfiles))

(define-record-type* <btrfs-subvolume>
  btrfs-subvolume
  %btrfs-subvolume
  btrfs-subvolume?
  (path btrfs-subvolume-path)
  (mount-point btrfs-subvolume-mount-point)
  (options btrfs-subvolume-options (default '())))

(define-record-type* <btrfs-swapfile>
  btrfs-swapfile
  %btrfs-swapfile
  btrfs-swapfile
  (path btrfs-swapfile-path)
  (size btrfs-swapfile-size))

(define (make-btrfs-partition file partition)
  (let* ((start (btrfs-partition-start partition))
	 (end (btrfs-partition-end partition))
	 (mount-point (btrfs-partition-mount-point partition))
	 (partition-mount-point mount-point)
	 (extra-args (btrfs-partition-extra-args partition))
	 (subvolumes (btrfs-partition-subvolumes partition))
	 (swapfiles (btrfs-partition-swapfiles partition)))
    (display (string-join (append
			   (list "mkfs.btrfs")
			   extra-args
			   (list file))))
    (newline)

    (display (string-join (list "mkdir" "-p" mount-point)))
    (newline)
    (display (string-join (list "mount" file mount-point)))
    (newline)

    (for-each
     (match-lambda
       (($ <btrfs-subvolume> path mount-point options)
	(begin
	  (display (string-join (list "btrfs" "subvolume" "create"
				      (string-append
				       partition-mount-point path))))
	  (newline)
	  (display (string-join (list "mkdir" "-p"
				      (string-append "/mnt" mount-point))))
	  (newline)
	  (display (string-join (list "mount" "-o"
				      (string-append "subvolume=" (basename path))
				      (string-append "/mnt" mount-point))))
	  (newline)
	  )))
     subvolumes)

    (for-each
     (lambda (swapfile)
       (display (string-join (list "btrfs" "filesystem" "mkswapfile"
				   "--size" (btrfs-swapfile-size swapfile)
				   (string-append "/mnt"
						  (btrfs-swapfile-path swapfile)))))
       (newline))
     swapfiles)
    ))

(define* (btrfs-partition->file-systems device partition
					#:key
					(root (or (getenv "INSTALLATION_ROOT")
						  "/mnt")))
  (map
   (lambda (subvolume)
     (file-system
      (mount-point (btrfs-subvolume-mount-point subvolume))
      (device device)
      (type "btrfs")
      (options (format #f "subvolume=~a~a"
		       (basename
			(btrfs-subvolume-path subvolume))
		       (let ((options (string-join
				       (btrfs-subvolume-options subvolume) ",")))
			 (if (not (null? (btrfs-subvolume-options subvolume)))
			     (string-append "," options) ""))))))
   (btrfs-partition-subvolumes partition)))

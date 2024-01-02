(define-module (disko partitions btrfs)
  #:use-module (guix records)
  #:use-module (disko utils)
  #:export (btrfs-partition
	    btrfs-partition?
	    btrfs-partition-size
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
	    btrfs-swapfile-size))

(define-record-type* <btrfs-partition>
  btrfs-partition
  make-btrfs-partition
  btrfs-partition?
  (size btrfs-partition-size)
  (mount-point btrfs-partition-mount-point)
  (extra-args btrfs-partition-extra-args)
  (subvolumes btrfs-partition-subvolumes)
  (swapfiles btrfs-partition-swapfiles))

(define-record-type* <btrfs-subvolume>
  btrfs-subvolume
  make-btrfs-subvolume
  btrfs-subvolume?
  (path btrfs-subvolume-path)
  (mount-point btrfs-subvolume-mount-point)
  (options btrfs-subvolume-options))

(define-record-type* <btrfs-swapfile>
  btrfs-swapfile
  make-btrfs-swapfile
  btrfs-swapfile
  (path btrfs-swapfile-path)
  (size btrfs-swapfile-size))

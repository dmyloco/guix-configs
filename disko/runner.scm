(define-module (disko runner)
  #:use-module (disko device)
  #:use-module (disko partitions vfat)
  #:use-module (disko partitions btrfs)
  #:use-module (disko partitioning)
  #:use-module (disko file-systems)
  #:use-module (gnu packages disk)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages admin)
  #:use-module (guix store)
  #:use-module (guix derivations)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (ice-9 pretty-print)
  #:export (run-disko))

(define (get-partition-start-end partition)
  (cond ((vfat-partition? partition)
	 (list (vfat-partition-start partition) (vfat-partition-end partition)))
	((btrfs-partition? partition)
	 (list (btrfs-partition-start partition) (btrfs-partition-end partition)))))

(define (display-disko-script devices)
  (for-each
   (lambda (i device)
     (part-disk (disko-device-file device)
		(disko-device-partitions device))
     (make-file-systems device)
     (newline))
   (iota (length devices)) devices)

  ;; (pretty-print (devices->file-systems devices))
  )

(define store (open-connection))

(define parted
  (let ((drv (package-derivation store parted)))
    (build-derivations store (list drv))
    (string-append (derivation->output-path drv)
		   "/sbin/parted")))

(define btrfs-progs
  (let ((drv (package-derivation store btrfs-progs)))
    (build-derivations store (list drv))
    (derivation->output-path drv)))

(define mkfs.btrfs (string-append btrfs-progs "/bin/mkfs.btrfs"))
(define btrfs (string-append btrfs-progs "/bin/mkfs.btrfs"))

(define mkfs.vfat
  (let ((drv (package-derivation store dosfstools)))
    (build-derivations store (list drv))
    (string-append (derivation->output-path drv) "/sbin/mkfs.vfat")))

(define bash
  (let ((drv (package-derivation store bash)))
    (build-derivations store (list drv))
    (string-append (derivation->output-path drv) "/bin/bash")))

(close-connection store)

(define (gen-disko-script devices)
  (let ((store (open-connection))
	(lower (lower-object
		(plain-file "disko-script"
			    (with-output-to-string
			      (lambda _ (display-disko-script devices)))))))
    ;; (define result (build-derivations store (list (lower store))))
    (define result (lower store))
    (close-connection store)
    result))

(define (run-disko devices)
  (for-each
   (lambda (prog)
     (setenv "PATH"
	     (format #f "~a:~a" (getenv "PATH")
		     (dirname prog))))
   (list parted
	 mkfs.btrfs
	 btrfs
	 mkfs.vfat))
  (system* bash (gen-disko-script devices)))

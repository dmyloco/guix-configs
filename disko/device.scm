(define-module (disko device)
  #:use-module (guix records)
  #:export (disko-device
	    disko-device?
	    disko-device-file
	    ;; disko-device-label
	    disko-device-partitions))

(define-record-type* <disko-device>
  disko-device
  make-disko-device
  disko-device?
  (file disko-device-file)
  (label disko-device-label (default "gpt")) ; Just don't change it (:
  (partitions disko-device-partitions))

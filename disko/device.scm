(define-module (disko device)
  #:use-module (guix records)
  #:export (disko-device
	    disko-device?))

(define-record-type* <disko-device>
  disko-device
  make-disko-device
  disko-device?
  (file disko-device-file)
  (label disko-device-label (default "gpt"))
  (partitions disko-device-partitions))

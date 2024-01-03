(use-modules (guix channels)
	     (guix ci))

(list
 (channel
  (name 'guix)
  (url "https://github.com/guix-mirror/guix")
  (branch "master"))
 (channel
  (name 'nonguix)
  (url "https://gitlab.com/nonguix/nonguix")
  (branch "master"))
 (channel
  (name 'rde)
  (url "https://git.sr.ht/~abcdw/rde")
  (branch "master")))

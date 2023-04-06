;;; maxima
(autoload 'imaxima "imaxima" "Image support for Maxima." t)
(autoload 'imath "imath" "Interactive Math mode" t)

(eval-after-load "imaxima"
  (lambda ()
    (message "imaxima loaded.  customize variables")
    (setq imaxima-pt-size 12)
    (setq imaxima-scale-factor 1.1)))

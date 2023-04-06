;; CC-mode
(require 'cl-lib)

(defvar tab-4-directories
  '("src/c++/camdrv_test/" "src/camdrv_test"))

(add-hook 'c-mode-common-hook
	  #'(lambda ()
	      (setq case-fold-search nil)
	      (c-set-style "bsd")
	      (when (cl-loop for path in tab-4-directories
			     when (cl-search path (buffer-file-name))
			     return t
			     finally (return nil))
		indent-tabs-mode nil)
	      (cl-pushnew '(case-label . 0) c-offsets-alist)))

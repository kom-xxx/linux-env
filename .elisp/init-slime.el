;;;
;;; hyper-spec slime lisp clojure
;;;
(setq common-lisp-hyperspec-root
      "file:///usr/local/share/doc/lisp/HyperSpec/HyperSpec/"
      common-lisp-hyperspec-symbol-table
      "/usr/local/share/doc/lisp/HyperSpec/HyperSpec/Data/Map_Sym.txt")

(push '("\\.asd$" . common-lisp-mode) auto-mode-alist)

(setq slime-net-coding-system 'utf-8-unix)

(require 'slime-autoloads)
(autoload 'cltl2-lookup "cltl2" "looking up cltl2 document" t)
(setq cltl2-root-url "file:///usr/local/share/doc/cltl")

(defun slime-module-list ()
  `(,@(if (featurep 'swank-clojure)
	  '(slime-repl ;;slime-autodoc
	    slime-c-p-c slime-editing-commands slime-fancy-inspector
	    slime-fuzzy slime-presentations slime-scratch slime-xref-browser
	    slime-references slime-package-fu slime-fontifying-fu)
	'(slime-fancy slime-indentation))
    slime-asdf slime-banner slime-indentation))

(add-hook 'lisp-mode-hook
	  (function (lambda ()
		      (slime-mode t)
		      (global-set-key "\C-cC" 'cltl2-lookup))))

(defun slime-lisp-setting ()
  (when (featurep 'swank-clojure)
    (add-to-list 'slime-lisp-implementations
		 `(clojure ,(swank-clojure-cmd) :init swank-clojure-init)
		 t #'cl-equalp))
  (add-to-list 'slime-lisp-implementations
	       '(clisp ("clisp") :coding-system utf-8-unix) nil #'cl-equalp)
  (add-to-list 'slime-lisp-implementations  
	       '(ecl ("env" "LANG=ja_JP.UTF-8" "ecl")) nil #'cl-equalp)
  (add-to-list 'slime-lisp-implementations  
	       '(ccl ("env" "LANG=ja_JP.UTF-8" "ccl64")
		     :coding-system utf-8-unix)
	       nil #'cl-equalp)
  (add-to-list 'slime-lisp-implementations 
	       '(sbcl ("env" "LANG=ja_JP.UTF-8" "sbcl"
		       "--dynamic-space-size" "32768"
		       "--control-stack-size" "1024")
		      :coding-system utf-8-unix)
	       nil #'cl-equalp))

(defun slime-setup-faces ()
  (set-face-foreground 'slime-reader-conditional-face "green4")
  (set-face-foreground 'slime-repl-output-face "LightGreen")
  (set-face-foreground 'slime-repl-result-face "GreenYellow")
  (set-face-foreground 'slime-repl-inputed-output-face "GreenYellow")
  (set-face-foreground 'sldb-restartable-frame-line-face "LemonChiffon"))

(eval-after-load "slime"
  '(progn
     ;;(load "js-expander")
     (slime-lisp-setting)
     (slime-setup (slime-module-list))
     (setq slime-complete-symbol*-fancy t)
     (setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)
     (setq slime-truncate-lines nil)
     (setq slime-enable-evaluate-in-emacs t)
     (slime-setup-faces)))

(add-hook 'lisp-mode-hook
          (lambda ()
            (cond ((not (featurep 'slime))
                   (require 'slime)
                   (normal-mode)))))

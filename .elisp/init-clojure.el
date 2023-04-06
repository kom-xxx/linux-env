(push "~/.elisp/clojure-mode" load-path)
(push "~/.elisp/swank-clojure" load-path)

;; clojure support
(require 'clojure-mode)
(autoload 'clojure-mode "clojure-mode" "A major mode for Clojure" t)

(require 'swank-clojure)
(require 'slime)
(defun slime-module-list ()
  `(,@(if (featurep 'swank-clojure-autoload)
	  '(slime-repl ;;slime-autodoc
	    slime-c-p-c 
	    slime-fuzzy)
	'(slime-fancy))
    slime-asdf slime-banner slime-indentation))
(slime-setup (slime-module-list))

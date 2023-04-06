;;; -*-emacs-lisp-*-
(require 'cl-lib)
(require 'info)

;;; window
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(show-paren-mode 1)
(normal-erase-is-backspace-mode 0)

(defun string-to-int (string)
  (string-to-number string))

(mapc #'(lambda (x) (cl-pushnew x default-frame-alist))
      '((width . 80) (height . 80)))

(when (getenv "SSH_CLIENT")
  (cl-pushnew
   '(font . "-*-DejaVu Sans Mono-normal-normal-normal-*-12-*-*-*-m-*-*-*")
   default-frame-alist))
	   
;;;; FONT on LAPTOP-KPTBO449(china)
;;;; "-*-DejaVu Sans Mono-normal-normal-normal-*-12-*-*-*-m-0-iso10646-1"
;;; options
(put 'narrow-to-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'set-goal-column 'disabled nil)
(put 'eval-expression 'disabled nil)

(setq inhibit-splash-screen t)
(setq eval-expression-print-level nil)
(setq eval-expression-print-length nil)
(setq scroll-conservatively 1)
(setq warning-suppress-types '((undo discard-info)))
(setq auto-save-list-file-prefix "~/.emacs.d/auto-saves/")
(setq-default case-fold-search nil)

(mapc #'(lambda (x) (cl-pushnew x Info-directory-list))
      '( "/usr/local/share/info/gcc10" "~/.sbcl/share/info"))

(mapc #'(lambda (x) (cl-pushnew x load-path))
      '("~/.elisp" "~/.elisp/share/emacs/site-lisp" "~/.elisp/slime"
	"~/.elisp/slime/contrib" "~/.elisp/haskell-mode" "~/src/acl2-8.0/emacs"
	"~/.elisp/imaxima"))

;;; 
(global-set-key "\M-," 'pop-tag-mark)
(global-set-key "\M-*" 'tags-loop-continue)

;;; face
(set-face-foreground 'minibuffer-prompt "LightGoldenrod")
(set-face-foreground 'error "brown1")
(set-face-foreground 'font-lock-builtin-face "turquoise3")
(set-face-foreground 'font-lock-comment-face "snow4")
(set-face-foreground 'font-lock-preprocessor-face "DarkCyan")
(set-face-foreground 'font-lock-string-face "SpringGreen3")
(set-face-foreground 'font-lock-function-name-face "SeaGreen2")
(set-face-foreground 'font-lock-variable-name-face "LightGoldenrod2")
(set-face-foreground 'font-lock-keyword-face "DarkSlateGray3")
(set-face-foreground 'font-lock-type-face "PaleGreen3")
(set-face-foreground 'font-lock-warning-face "DarkGoldenrod1")
;(set-face-foreground 'font-lock-doc-face "DarkOrange4")
(set-face-background 'region "sea green")

;; Language system
(set-language-environment 'Japanese)
;(coding-system-put 'cp932 :encode-translation-table
;		   (get 'japanese-ucs-jis-to-cp932-map 'translation-table))
(require 'mozc)
(setq default-input-method "japanese-mozc")
(set-default-coding-systems 'utf-8)
(modify-coding-system-alist 'file "\\.utf8\\.jp\\'" 'utf-8)

(require 'package)
(setq package-archives
      '(("melpa" . "http://melpa.org/packages/")
	("gnu"   . "http://elpa.gnu.org/packages/")
        ("org"   . "http://orgmode.org/elpa/")))
(package-initialize)

;;; package initialize
;;(load "google-c-style")
;;(load "init-gtags")
;;(load "init-auctex")
;;(load "init-browse-url")
(load "init-cc-mode")
(load "init-comint")
;;(load "init-imaxima")
(load "init-mew")
(load "init-python")
(load "init-sh")
;;(load "init-slime")
(load "init-verilog")



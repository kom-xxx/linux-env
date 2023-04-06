;;; Python mode

(setq auto-mode-alist (cons '("\\.py$" . python-mode) auto-mode-alist))
(setq interpreter-mode-alist
      (cons '("pthon3" . python-mode) interpreter-mode-alist))
(autoload 'python-mode "python-mode" "Python editing mode." t)

(add-hook 'python-mode-hook
	  (lambda ()
	    (define-key python-mode-map [delete] 'py-electric-backspace)
	    (define-key python-mode-map [backspace] 'py-electric-delete)
	    (setf py-python-command "python3.9")))

(add-hook 'python-shell-hook
	  (lambda ()
	    (normal-erase-is-backspace-mode 0)
	    (define-key py-shell-map [backspace] 'delete-forward-char)
	    (define-key py-shell-map [delete] 'delete-backward-char)
	    (define-key py-shell-map [kp-delete] 'delete-backward-char)))

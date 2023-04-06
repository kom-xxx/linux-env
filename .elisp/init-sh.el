(defun sh-faces ()
  (set-face-foreground 'sh-escaped-newline "deep sky blue")
  (set-face-foreground 'sh-heredoc "medium blue")
  (set-face-foreground 'sh-quoted-exec "MediumPurple1"))

(add-hook 'sh-mode-hook
	  (lambda ()
	    (normal-erase-is-backspace-mode -1)
	    (setq sh-indent-for-case-label 0)
	    (setq sh-indent-for-case-alt '+)
	    (sh-faces)))

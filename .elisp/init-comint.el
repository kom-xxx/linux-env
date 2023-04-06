;;
;; shell-mode, etc
;;
(add-hook 'comint-mode-hook
	  #'(lambda ()
	      (setq comint-prompt-read-only t)
	      (normal-erase-is-backspace-mode 0)
	      (substitute-key-definition 'delete-char
					 'backward-delete-char-untabify
					 comint-mode-map)
	      (substitute-key-definition 'kill-line `comint-kill-whole-line
					 comint-mode-map)
	      (substitute-key-definition 'kill-line `comint-kill-region
					 comint-mode-map)
	      (define-key comint-mode-map [backspace] 'delete-forward-char)
	      (define-key comint-mode-map [delete] 'delete-backward-char)
	      (define-key comint-mode-map [kp-delete] 'delete-backward-char)))

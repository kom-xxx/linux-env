(defun eshell-face ()
   (set-face-foreground 'eshell-prompt "turquoise4")
   (set-face-foreground 'eshell-ls-archive "black")
   (set-face-foreground 'eshell-ls-backup "black")
   (set-face-foreground 'eshell-ls-clutter "black")
   (set-face-foreground 'eshell-ls-directory "black")
   (set-face-foreground 'eshell-ls-executable "black")
   (set-face-foreground 'eshell-ls-missing "black")
   (set-face-foreground 'eshell-ls-product "black")
   (set-face-foreground 'eshell-ls-readonly "black")
   (set-face-foreground 'eshell-ls-special "black")
   (set-face-foreground 'eshell-ls-symlink "black")
   (set-face-foreground 'eshell-ls-unreadable "brack"))


(add-hook 'eshell-mode-hook
	  (lambda ()
	    (eshell-face)
	    (setq eshell-prompt-function
		  (lambda ()
		    (concat (getenv "USER") "@" (getenv "HOSTNAME")
			    (if (= (user-uid) 0) "# " "$ "))))))

     
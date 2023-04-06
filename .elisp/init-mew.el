;;; Mew
(autoload 'mew "mew" nil t)
(autoload 'mew-send "mew" nil t)

;; Optional setup (Read Mail menu):
(setq read-mail-command 'mew)

;; Optional setup (e.g. C-xm for sending a message):
(autoload 'mew-user-agent-compose "mew" nil t)
(if (boundp 'mail-user-agent)
    (setq mail-user-agent 'mew-user-agent))
(if (fboundp 'define-mail-user-agent)
    (define-mail-user-agent
      'mew-user-agent
      'mew-user-agent-compose
      'mew-draft-send-message
      'mew-draft-kill
      'mew-send-hook))
(setq mew-mail-domain "narihara-lab.jp")

;;; read from mail-drop
(setq mew-mailbox-type 'mbox)
(setq mew-mbox-command "incm")
(setq mew-mbox-command-arg "-u -d /var/mail/kom")

(setq mew-mail-path "~/.Mail")

(add-hook 'mew-message-mode-hook
	  (lambda ()
	    (set-face-foreground 'mew-face-body-url "medium sea green")
	    (set-face-foreground 'mew-face-header-subject "thistle")))

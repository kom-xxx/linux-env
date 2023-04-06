(cl-pushnew "~/.cabal/bin" exec-path)

;; (setq haskell-program-name
;;       (or (cond
;; 	   ((not (fboundp 'executable-find)) nil)
;; 	   ((executable-find "ghci") "ghci")
;; 	   ((executable-find "hugs") "hugs \"+.\""))))

(require 'inf-haskell)

(load "haskell-site-file")

(autoload 'ghc-init "ghc" nil t)
(autoload 'ghc-debug "ghc" nil t)

(setq ghc-display-error 'other-buffer)

(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
(add-hook 'haskell-mode-hook (lambda () (ghc-init)))

;; (autoload 'haskell-mode "haskell-mode")
;; (autoload 'haskell-mode "inf-haskell")
;; (autoload 'haskell-cabal "haskell-cabal")

;; (add-to-list 'auto-mode-alist '("\\.hs$" . haskell-mode))
;; (add-to-list 'auto-mode-alist '("\\.lhs$" . haskell-mode))
;; (add-to-list 'auto-mode-alist '("\\.cabal\\'" . haskell-cabal-mode))

;; (add-to-list 'interpreter-mode-alist '("runghc" . haskell-mode))
;; (add-to-list 'interpreter-mode-alist '("runhaskell" . haskell-mode))

;; (add-hook 'haskell-mode-hook (lambda () (turn-on-haskell-indentation)))



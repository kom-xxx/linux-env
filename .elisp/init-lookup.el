;;;; Lookup
(autoload 'lookup "lookup" nil t)
(autoload 'lookup-region "lookup" nil t)
(autoload 'lookup-other-frame "lookup" nil t)
(autoload 'lookup-region-other-frame "lookup" nil t)
(autoload 'lookup-pattern-other-frame "lookup" nil t)
(define-key ctl-x-map "\C-y" 'lookup-pattern-other-frame)
(setq lookup-search-agents '((ndtp "localhost") (ndspell)))

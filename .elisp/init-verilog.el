(add-hook 'verilog-mode-hook
	  #'(lambda ()
	      (define-key verilog-mode-map [backspace] 'delete-char)
	      (define-key verilog-mode-map
		[delete] 'backward-delete-char-untabify)))

(custom-set-variables
 '(verilog-align-ifelse t)
 '(verilog-auto-delete-trailing-whitespace t)
 '(verilog-auto-inst-param-value t)
 '(verilog-auto-inst-vector nil)
 '(verilog-auto-lineup (quote all))
 '(verilog-auto-newline nil)
 '(verilog-auto-save-policy nil)
 '(verilog-auto-template-warn-unused t)
 '(verilog-case-indent 3)
 '(verilog-cexp-indent 3)
 '(verilog-highlight-grouping-keywords t)
 '(verilog-highlight-modules t)
 '(verilog-indent-level 3)
 '(verilog-indent-level-behavioral 3)
 '(verilog-indent-level-declaration 3)
 '(verilog-indent-level-module 3)
 '(verilog-tab-to-comment nil))

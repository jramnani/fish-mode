;;; fish-mode.el --- Major mode for editing Fish shell scripts

;; Copyright (C) 2014 Jeff Ramnani

;; Author: Jeff Ramnani <jeff@jefframnani.com>
;; Created: 29 Dec 2014
;; Keywords: languages
;; Homepage: https://github.com/jramnani/fish-mode
;; Package-Version: 0.1.0

;; This file is not part of GNU Emacs.

;; This file is free software.  You can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 2 of the License, or
;; (at your option) any later version.


;;; Code

(defvar fish-builtin-commands
  '("alias" "and"
    "begin" "bg" "bind" "block" "break" "breakpoint" "builtin"
    "case" "cd" "command" "commandline" "complete" "contains" "continue" "count"
    "dirh" "dirs"
    "echo" "else" "emit" "end" "eval" "exec" "exit"
    "fg" "fish" "fish_config" "fish_indent" "fish_pager" "fish_prompt" "fish_right_prompt"
    "fish_update_completions" "fishd" "for" "funced" "funcsave" "function" "functions"
    "help" "history"
    "if" "isatty"
    "jobs"
    "math" "mimedb"
    "nextd" "not"
    "open" "or"
    "popd" "prevd" "psub" "pushd" "pwd"
    "random" "read" "return"
    "set" "set_color" "source" "status" "switch"
    "test" "trap" "type"
    "ulimit" "umask" "vared" "while"))

(defvar fish-builtin-commands-re
  (regexp-opt fish-builtin-commands 'words))

(defvar fish-font-lock-keywords-1
  (list
   ;; $VARIABLE
   (cons "\\$\\([[:alpha:]_][[:alnum:]_]*\\)" 'font-lock-variable-name-face)
   ;; set VARIABLE
   (cons "set \\([[:alpha:]_][[:alnum:]_]*\\)" '(1 font-lock-variable-name-face))
   ;; set -lx VARIABLE
   (cons "set \\(-[[:word:]]*\\)* \\([[:alpha:]_][[:alnum:]_]*\\)" '(2 font-lock-variable-name-face))
   (cons "function \\(\\sw+\\)" '(1 font-lock-function-name-face))
   (cons fish-builtin-commands-re 'font-lock-builtin-face)
   ))

(defvar fish-mode-syntax-table
  (let ((tab (make-syntax-table text-mode-syntax-table)))
    (modify-syntax-entry ?\# "<" tab)
    (modify-syntax-entry ?\n ">" tab)
    (modify-syntax-entry ?\" "\"\"" tab)
    (modify-syntax-entry ?\' "\"'" tab)
    (modify-syntax-entry ?_ "w" tab)
    (modify-syntax-entry ?. "w" tab)
    (modify-syntax-entry ?/ "w" tab)
    (modify-syntax-entry ?- "w" tab)
    (modify-syntax-entry ?$ "_" tab)
    (modify-syntax-entry ?= "." tab)
    (modify-syntax-entry ?& "." tab)
    (modify-syntax-entry ?| "." tab)
    (modify-syntax-entry ?< "." tab)
    (modify-syntax-entry ?> "." tab)
    tab)
  "Syntax table used in Fish-mode buffers.")


;; Indentation

(defcustom fish-smie-indent-basic 4
   "Indentation level for Fish shell's SMIE configuration"
   :group 'fish
   :type 'integer
   :safe 'integerp)

(defcustom fish-indent-debug nil
  "Setting to true value will cause the indentation enging to print
debug messages to the *Messages* buffer."
  :group 'fish
  :type 'boolean
  :safe 'booleanp)


(require 'smie)

;; Grammar
(defconst fish-smie-grammar
  (smie-prec2->grammar
   (smie-bnf->prec2
    '((exp)  ; A constant, or a $var, or a sequence of them
      (cmd ("if" cmd "end")
           ("if" cmd "else" cmd "end")
           ("if" cmd "else if" cmd "else" cmd "end")
           ("for" exp "in" cmd "end")
           ("function" cmd "end")
           (cmd "|" cmd)
           (cmd "&&" cmd)
           (cmd "||" cmd)
           (cmd ";" cmd)
           (cmd "&" cmd)))
    '((assoc "case") (assoc ";" "&") (assoc "&&" "||") (assoc "|")))))


;; Tokenizers
(defun fish-smie-forward-token ()
  (forward-comment (point-max))
  (cond
   ;; If there is nothing but whitespace between the last token and eol,
   ;; emit a semicolon to close the statement.
   ;; This prevent rules from "hanging".
   ((looking-at (rx (and (1+ space) eol)))
    (goto-char (match-end 0))
    ";")
   ((looking-at fish-builtin-commands-re)
    (goto-char (match-end 0))
    (match-string-no-properties 0))
   (t (buffer-substring-no-properties
       (point)
       (progn
         (skip-syntax-forward "w_.")
         (point))))))

(defun fish-smie-backward-token ()
  (let ((pos (point)))
    (forward-comment (- (point)))
    (cond
     ;; Emit an implicit semicolon to prevent a rule from "hanging"
     ((> pos (line-end-position))
      ";")
     ((looking-back fish-builtin-commands-re (- (point) 2) t)
      (goto-char (match-beginning 0))
      (match-string-no-properties 0))
     (t (buffer-substring-no-properties
         (point)
         (progn
           (skip-syntax-backward "w_.")
           (point)))))))

;; Indentation rules
(defun fish-smie-rules (kind token)
  (pcase (cons kind token)
    (`(:elem . basic) fish-smie-indent-basic)
    (`(:before . ";")
     (cond
      ((smie-rule-parent-p "begin" "function")
       (smie-rule-parent fish-smie-indent-basic))))
    (`(:after . ";")
     (cond
      ((smie-rule-parent-p "function")
       (smie-rule-parent))
      (t
       (if (smie-rule-hanging-p)
           (smie-rule-parent)
         (smie-rule-parent fish-smie-indent-basic)))))
    (`(,_ . ,(or ",")) (smie-rule-separator kind))
    (`(:after . "end") 0)
    (`(:before . "if")
     (and (not (smie-rule-bolp))
          (smie-rule-prev-p "else")
          (smie-rule-parent)))))

(defun fish-smie-rules-verbose (kind token)
  (let ((value (fish-smie-rules kind token)))
    (if fish-indent-debug
        (message "fish-smie-rules -> %s '%s'; bolp:%s sibling-p:%s parent:%s hanging:%s == %s"
                 kind
                 token
                 (ignore-errors (smie-rule-bolp))
                 (ignore-errors (smie-rule-sibling-p))
                 (ignore-errors smie--parent)
                 (ignore-errors (smie-rule-hanging-p))
                 value))
    value))


;; Autoloads

;;;###autoload
(define-derived-mode fish-mode prog-mode "Fish"
  "Major mode for editing fish shell files."
  :syntax-table fish-mode-syntax-table
  (setq-local font-lock-defaults '(fish-font-lock-keywords-1))
  (setq-local comment-start "# ")
  (setq-local comment-start-skip "#+[\t ]*")
  ;; Wire up SMIE for indentation
  (smie-setup fish-smie-grammar #'fish-smie-rules-verbose
              :forward-token #'fish-smie-forward-token
              :backward-token #'fish-smie-backward-token))


;;;###autoload
(add-to-list 'auto-mode-alist (cons (purecopy "\\.fish\\'")  'fish-mode))

;;;###autoload
(add-to-list 'interpreter-mode-alist (cons (purecopy "fish")  'fish-mode))

(provide 'fish-mode)

;;; fish-mode.el ends here

;;; test-helper.el --- Test helper

;;; Commentary
;;

;;; Code

;; Don't use tabs
(setq-default indent-tabs-mode nil)
;; My tests currently assume a tab-width of 4
(setq-default default-tab-width 4)

(require 'ert)

;; cursor-test helps test indentation
(require 'cursor-test)

;; Load the fish-mode under test
(require 'fish-mode)

(provide 'test-helper)

;; test-helper.el ends here

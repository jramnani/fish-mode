;; Set up load paths
;; Current dir
(add-to-list 'load-path (file-name-directory
                         (or load-file-name buffer-file-name)))

;; Package dir
(add-to-list 'load-path (concat (expand-file-name user-emacs-directory)
                                "elpa"))

;; Wire up packaging to use third-party package 'cursor-test' which helps
;; test indentation
(package-initialize)
(require 'use-package)

;; Don't use tabs
(setq-default indent-tabs-mode nil)
;; My tests currently assume a tab-width of 4
(setq-default default-tab-width 4)

(require 'ert)
(require 'fish-mode)

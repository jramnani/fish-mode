;;; fish-mode-test.el -- Fish mode test suite

;;; Commentary
;;

;;; Code:

(require 'ert)
(require 'fish-mode)

;; Borrowed from Emacs' internal tests for python-mode
(defmacro fish-tests-with-temp-buffer (contents &rest body)
  "Create a `fish-mode' enabled temp buffer with CONTENTS.
BODY is code to be executed within the temp buffer.  Point is
always located at the beginning of buffer."
  (declare (indent 1) (debug t))
  `(with-temp-buffer
     (fish-mode)
     (insert ,contents)
     (goto-char (point-min))
     ,@body))

(ert-deftest fish-tests-provides-feature ()
  "Major modes should register themselves in the list of features"
  (fish-tests-with-temp-buffer
   ""
    (should (equal (featurep 'fish-mode) t))))

(ert-deftest fish-tests-syntax-highlighting ()
  "Fish shell should provide syntax highlighting"
  ;; These are pretty simple tests right now.
  (fish-tests-with-temp-buffer
      "echo 'hello world'"
    ;; Fontify the buffer.  There will be no text properties if you don't do this.
    (font-lock-fontify-buffer)

    ;; Move point to the 'e' character of "echo"
    (goto-char (point-min))

    ;; The command "echo" is a Fish builtin function
    (should (equal (get-text-property (point) 'face)
                   'font-lock-builtin-face))))


(ert-deftest fish-tests-should-indent-function-body ()
  "Test simple indentation of a function body"
  (cursor-test/equal*
   :description "Test indentation of simple function body"
   :init "
function foo|
"
   :exercise (lambda ()
               (fish-mode)
               (newline-and-indent))
   :expect "
function foo
    |
"))

(ert-deftest fish-tests-should-unindent-after-function-body ()
  ""
  (cursor-test/equal*
   :description "Should unindent by fish-indent-offset after seeing an 'end' keyword"
   :init "
function foo
    echo hello world
end|
"
   :exercise (lambda ()
               (fish-mode)
               (newline-and-indent))
   :expect "
function foo
    echo hello world
end
|"))

;; fish-mode-test.el ends here

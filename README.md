# Fish Mode

An Emacs major mode for editing [Fish shell](http://fishshell.com/) scripts.

Provides font-locking, and indentation support.

**Current status:** Experimental.

* Indentation doesn't work right, yet.  Still learning how to use the
indentation engine, [SMIE](https://www.gnu.org/software/emacs/manual/html_node/elisp/SMIE.html#SMIE).
* Font locking could be better. Currently, all builtin commands use the same
font face.


## Testing

The tests for indentation use a third-party package named,
[cursor-test](https://github.com/ainame/cursor-test.el), which is
available via MELPA.

You can run the tests from the command line using the Fish script,
`run-fish-tests.fish`.  You are using Fish shell, right? ;) It should be
trivial to port to Bash if need be.


## Acknowledgements

I've learned a lot from reading the code for existing modes. If you've
written or contributed to any of these, Thank You!

* [elixir-mode](https://github.com/mattdeboard/emacs-elixir)
* [python-mode](http://git.savannah.gnu.org/cgit/emacs.git/tree/lisp/progmodes/python.el)
* [ruby-mode](http://git.savannah.gnu.org/cgit/emacs.git/tree/lisp/progmodes/ruby-mode.el)
* [sh-script-mode](http://git.savannah.gnu.org/cgit/emacs.git/tree/lisp/progmodes/sh-script.el)

There is another major mode for Fish [on GitHub](https://github.com/wwwjfy/emacs-fish) that
you can try to see if it works for you.

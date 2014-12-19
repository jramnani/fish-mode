#!/usr/bin/env fish

set -l OUTPUT /tmp/fish-shell-tests-output.txt

# Run the tests
emacs --batch --load ert-bootstrap.el --load ./fish-mode-tests.el -f ert-run-tests-batch-and-exit 2>$OUTPUT

if test $status = 0
    echo "Success -- All tests passed"
    rm $OUTPUT
else
    cat $OUTPUT
    echo "FAIL - one or more tests failed"
end

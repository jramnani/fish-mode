#!/usr/bin/env fish

set -l OUTPUT /tmp/fish-shell-tests-output.txt

# Install dependencies via Cask
cask install

# Run the tests
cask exec ert-runner -L .

if test $status = 0
    echo "Success -- All tests passed"
    rm $OUTPUT
else
    cat $OUTPUT
    echo "FAIL - one or more tests failed"
end

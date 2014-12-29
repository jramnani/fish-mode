#!/usr/bin/env fish

# Install dependencies via Cask
cask install

# Run the tests
cask exec ert-runner -L .

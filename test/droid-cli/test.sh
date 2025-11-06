#!/bin/bash -i
set -e

source dev-container-features-test-lib

check "droid is on PATH" which droid
check "droid reports version" droid --version
check "ripgrep is on PATH" which rg

reportResults

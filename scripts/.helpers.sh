#!/bin/bash

function version_ge () {
  perl -e '($s, $t) = map { [split /\./, (/([0-9.]+)/)[0]] } @ARGV; while(@$t){ shift(@$s) >= shift(@$t) or exit(1) }' -- "$@"
}

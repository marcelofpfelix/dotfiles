#!/bin/sh
set -u

check="${1:?usage: run-check.sh check-command}"

"$check" 2>/dev/null \
    | sed 's/#\[[^]]*\]//g' \
    | awk '{gsub(/\033\[[0-9;]*[A-Za-z]/, ""); print}' \
    | tr '\r\n' '  ' \
    | sed 's/[[:space:]][[:space:]]*/ /g; s/^ //; s/ $//'

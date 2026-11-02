#!/usr/bin/env bash
set -euo pipefail

output="$(./bin/ada-compiler examples/hello.adb)"
printf '%s\n' "$output"

grep -q '^IDENTIFIER with$' <<<"$output"
grep -q '^IDENTIFIER Ada$' <<<"$output"
grep -q '^IDENTIFIER procedure$' <<<"$output"
grep -q '^IDENTIFIER Hello$' <<<"$output"
grep -q '^IDENTIFIER begin$' <<<"$output"

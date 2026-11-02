#!/usr/bin/env bash
set -euo pipefail

tokens="$(./bin/ada_compiler_cli --tokens examples/hello.adb)"
printf '%s\n' "$tokens"

grep -q '^IDENTIFIER with$' <<<"$tokens"
grep -q '^IDENTIFIER Ada$' <<<"$tokens"
grep -q '^IDENTIFIER procedure$' <<<"$tokens"
grep -q '^IDENTIFIER Hello$' <<<"$tokens"
grep -q '^STRING_LITERAL "Hello, Ada compiler!"$' <<<"$tokens"

parsed="$(./bin/ada_compiler_cli examples/hello.adb)"
printf '%s\n' "$parsed"

grep -q '^COMPILATION_UNIT \[parent: 0\]$' <<<"$parsed"
grep -q '^CONTEXT_CLAUSE Ada.Text_IO \[parent: 1\]$' <<<"$parsed"
grep -q '^SUBPROGRAM_BODY Hello \[parent: 1\]$' <<<"$parsed"
grep -q '^PROCEDURE_CALL Ada \[parent: 3\]$' <<<"$parsed"

if ./bin/ada_compiler_cli tests/fixtures/bad_end_name.adb > /tmp/ada-parser-invalid.out 2>&1; then
  echo "expected parser to reject mismatched end name" >&2
  exit 1
fi
grep -q 'end name does not match procedure name' /tmp/ada-parser-invalid.out

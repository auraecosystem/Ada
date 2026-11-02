#!/usr/bin/env bash
set -euo pipefail

tokens="$(./bin/ada-compiler --tokens examples/hello.adb)"
printf '%s\n' "$tokens"

grep -q '^IDENTIFIER with$' <<<"$tokens"
grep -q '^IDENTIFIER Ada$' <<<"$tokens"
grep -q '^IDENTIFIER procedure$' <<<"$tokens"
grep -q '^IDENTIFIER Hello$' <<<"$tokens"
grep -q '^STRING_LITERAL "Hello, Ada compiler!"$' <<<"$tokens"

parsed="$(./bin/ada-compiler examples/hello.adb)"
printf '%s\n' "$parsed"

grep -q '^CONTEXT_CLAUSE Ada.Text_IO$' <<<"$parsed"
grep -q '^SUBPROGRAM_BODY Hello$' <<<"$parsed"
grep -q '^PROCEDURE_CALL Ada$' <<<"$parsed"
grep -q '^COMPILATION_UNIT$' <<<"$parsed"

# Compiler Architecture

## Current implementation

The first bootstrap milestone contains a native Ada package hierarchy and a lexer API. The lexer recognizes identifiers, integer-like numeric tokens, punctuation, line comments, and end-of-input. It is intentionally not presented as a complete Ada lexical implementation.

## Planned pipeline

`source → lexer → parser → AST → name resolution → type/semantic analysis → IR → optimization → backend`

The runtime and standard library are separate deliverables. External compiler adapters must not become hidden dependencies of the native frontend.

## Design constraints

1. Preserve source offsets and evolve them into line/column source spans.
2. Keep syntax recognition separate from semantic legality checks.
3. Represent diagnostics as structured data, not formatted strings.
4. Make compiler stages independently testable.
5. Bound memory and recursion when processing untrusted source.
6. Record language-version decisions explicitly.

## Initial limitations

The bootstrap lexer does not yet implement Ada character/string literal rules, based literals, numeric separators, reserved-word classification, multi-character delimiters, Unicode identifier policy, or full lexical diagnostics. The CLI currently reads input line by line and is only a smoke-test driver.

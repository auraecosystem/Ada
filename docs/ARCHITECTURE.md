# Compiler Architecture

## Current implementation

The native frontend now has a token stream and a first recursive-descent parser. The lexer recognizes identifiers, integer-like numeric tokens, string and character literals, common compound delimiters, punctuation, line comments, and end-of-input.

The parser currently accepts a deliberately narrow compilation-unit subset:
- zero or more simple `with Unit.Name;` context clauses;
- one procedure body with an `is` and `begin` section;
- semicolon-terminated statements, with basic classification of `null`, procedure calls, assignments, and other statements;
- an optional matching procedure name after `end`.

The AST is a source-spanned node sequence. It is an initial syntax representation, not yet a complete hierarchical Ada AST.

## Pipeline

`source → lexer → parser → syntax nodes + diagnostics → (planned) name resolution → type/semantic analysis → IR → optimization → backend`

The runtime and standard library are separate deliverables. External compiler adapters must not become hidden dependencies of the native frontend.

## Design constraints

1. Preserve source offsets and evolve them into line/column source spans.
2. Keep syntax recognition separate from semantic legality checks.
3. Represent diagnostics as structured data, not formatted strings.
4. Make compiler stages independently testable.
5. Bound memory and recursion when processing untrusted source.
6. Record language-version decisions explicitly.

## Current parser limitations

This parser is not a full Ada grammar. It does not yet parse package declarations, functions, parameter/type declarations, nested declarative constructs, control-flow statements, exception handlers, generic units, tasking, or expressions into typed ASTs. Statement parsing currently scans to a semicolon and classifies only a few statement forms. The lexer still lacks complete Ada numeric-literal validation, reserved-word classification, Unicode identifier policy, and precise lexical diagnostics.

# Compiler Architecture

## Current implementation

The native frontend consists of a lexer, a restricted compilation-unit parser, and a separately testable expression parser.

The lexer recognizes identifiers, integer-like numeric tokens, string and character literals, common compound delimiters, punctuation, line comments, and end-of-input.

The compilation-unit parser currently accepts:
- simple `with Unit.Name;` context clauses;
- one procedure body with an `is` and `begin` section;
- semicolon-terminated statements, with basic classification of `null`, procedure calls, assignments, and other statements;
- an optional matching procedure name after `end`.

Compilation-unit nodes use parent indices: the root has parent 0, context clauses and the body point to the root, and statements point to the body.

The expression parser is independently callable through the CLI's `--expr` mode. It recognizes identifiers, integer/string/character literals, parentheses, unary `+`, `-`, `not`, and binary operators with precedence tiers:
1. `or`, `xor`;
2. `and`;
3. relational operators;
4. `+`, `-`, concatenation `&`;
5. `*`, `/`, `mod`, `rem`;
6. exponentiation `**` (right associative).

Expression nodes preserve byte offsets and parent indices. This is a foundational expression grammar, not yet the complete Ada expression grammar and not yet integrated into assignment/call statement nodes.

## Pipeline

`source → lexer → compilation-unit parser / expression parser → AST + diagnostics → name resolution → type/semantic analysis → IR → backend`

## Current limitations

The project is not a complete Ada compiler. It does not yet parse packages, functions, parameter profiles, declarations, control flow, exception handlers, generics, tasking, or full expression syntax such as qualified expressions, aggregates, attributes, membership tests, and range expressions. Numeric literal validation, reserved-word classification, Unicode identifier policy, line/column diagnostics, error recovery, semantic analysis, code generation, and ACATS execution remain future work.

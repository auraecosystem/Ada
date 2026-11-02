# Development Roadmap

## Milestone 0 — Repository bootstrap
- [x] Establish source layout and GPR project.
- [x] Add native lexer API and CLI smoke-test driver.
- [x] Build and run with GNAT/GPRbuild in CI.
- [ ] Add comprehensive lexer unit tests and structured lexical diagnostics.

## Milestone 1 — Lexical correctness
- [x] Recognize string and character literal token boundaries.
- [x] Recognize common compound delimiters and preserve source offsets.
- [x] Skip line comments without discarding following source lines.
- [ ] Complete Ada numeric literal rules, reserved words, and identifier legality.
- [ ] Add line/column positions and lexical diagnostics.

## Milestone 2 — Syntax
- [x] Parse simple context clauses and procedure bodies.
- [x] Classify basic statement forms and validate matching end names.
- [x] Add parent-indexed compilation-unit AST relationships.
- [x] Add a separate expression parser with operator precedence and parent-indexed expression nodes.
- [ ] Integrate expression ASTs into assignments and procedure calls.
- [ ] Add packages, functions, parameter profiles, declarations, and control flow.
- [ ] Implement complete grammar coverage, recovery, and regression tests.

## Milestone 3 — Semantic foundation
- [ ] Symbol tables, scopes, visibility, and name resolution.
- [ ] Type model, overload resolution, and legality rules.

## Milestone 4 — Executable compiler
- [ ] Typed intermediate representation.
- [ ] First backend, runtime contract, and end-to-end examples.

## Milestone 5 — Verification
- [ ] Unit, integration, regression, fuzz, and differential tests.
- [ ] ACATS harness integration and evidence-backed conformance reporting.

## Milestone 6 — LMLM integration
- [ ] Versioned compiler adapter protocol.
- [ ] Sandboxed compilation/execution and artifact provenance.
- [ ] Policy-controlled tool invocation.

## Release gates
No milestone is complete until its tests run in CI. Do not claim full Ada conformance without a documented test scope, exact toolchain revisions, logs, and reproducible results.

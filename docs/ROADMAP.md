# Development Roadmap

## Milestone 0 — Repository bootstrap
- [x] Establish source layout and GPR project.
- [x] Add an initial native Ada lexer API and CLI smoke-test driver.
- [ ] Build and run with GNAT/GPRbuild in CI.
- [ ] Add comprehensive lexer unit tests and structured lexical diagnostics.

## Milestone 1 — Lexical correctness
- [x] Recognize string and character literal token boundaries.
- [x] Recognize common compound delimiters and preserve source offsets.
- [x] Skip line comments without discarding following source lines.
- [ ] Implement complete Ada numeric literal rules and validation.
- [ ] Implement reserved-word classification and identifier legality.
- [ ] Add line/column source positions and full lexical diagnostics.

## Milestone 2 — Syntax
- [x] Define an initial AST node and source-span API.
- [x] Parse simple context clauses and procedure bodies.
- [x] Classify null statements, procedure calls, and assignments.
- [x] Diagnose missing delimiters and mismatched procedure end names.
- [ ] Expand to the selected Ada grammar revision, including packages, functions, declarations, expressions, and control flow.
- [ ] Implement robust error recovery and hierarchical AST nodes.
- [ ] Add parser golden tests and malformed-input regression tests.

## Milestone 3 — Semantic foundation
- Symbol tables and scopes.
- Visibility and name resolution.
- Type model, overload resolution, legality rules, and diagnostics.

## Milestone 4 — Executable compiler
- Typed intermediate representation.
- First backend and runtime contract.
- End-to-end executable examples.

## Milestone 5 — Verification
- Unit, integration, regression, fuzz, and differential tests.
- ACATS harness integration using the official suite and its instructions.
- Evidence-backed reports with explicit unsupported/not-applicable states.

## Milestone 6 — LMLM integration
- A versioned compiler adapter protocol.
- Sandboxed compilation and execution.
- Structured diagnostics and artifact provenance.
- Policy-controlled tool invocation.

## Release gates
No milestone is complete until its tests run in CI. No conformance claim is permitted without a documented test scope, exact toolchain/compiler revisions, logs, and reproducible results.

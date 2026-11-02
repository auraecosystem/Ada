# Development Roadmap

## Milestone 0 — Repository bootstrap
- [x] Establish source layout and GPR project.
- [x] Add an initial native Ada lexer API and CLI smoke-test driver.
- [ ] Build and run with GNAT/GPRbuild in CI.
- [ ] Add lexer unit tests and structured diagnostics.

## Milestone 1 — Lexical correctness
- Implement Ada reserved words, delimiters, comments, identifiers, numeric literals, character and string literals.
- Preserve line, column, and byte/source offsets.
- Add positive and negative lexical test cases.

## Milestone 2 — Syntax
- Define a versioned grammar scope.
- Implement parser, AST nodes, source spans, and recovery.
- Add parser golden tests and malformed-input tests.

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

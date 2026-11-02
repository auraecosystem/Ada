# Ada — Independent Ada Compiler Project

**Status:** native lexer and initial parser development  
**Repository:** [auraecosystem/Ada](https://github.com/auraecosystem/Ada)

This repository is the home of an independently developed Ada language implementation: lexer, parser, semantic analysis, type checking, intermediate representation, code generation, runtime, tooling, and conformance infrastructure.

The project is not currently an Ada-conforming compiler. GNAT is used as the bootstrap build tool and may be used for differential testing; it is not the parser or compiler backend.

## Project principles
- Preserve Ada language semantics and document the targeted language revision.
- Prefer small, independently testable compiler stages.
- Keep diagnostics deterministic and source-located.
- Treat compiler inputs as untrusted.
- Never claim ACATS conformance without recorded, reproducible test evidence.
- Keep external compiler adapters separate from the native compiler.

## Repository layout
- `src/` — native Ada compiler implementation.
- `cli/` — command-line entry point.
- `tests/` — unit and integration tests.
- `docs/` — architecture, language scope, and conformance policy.
- `acats/` — integration instructions and locally supplied ACATS material (not redistributed here).
- `adapters/` — optional external compiler integrations.
- `examples/` — small Ada input programs.

## Build

Requires GNAT (GCC Ada) and GPRbuild.

```sh
gprbuild -P ada_compiler.gpr
```

Run the native parser on the included example:

```sh
./bin/ada-compiler examples/hello.adb
```

Inspect lexical tokens:

```sh
./bin/ada-compiler --tokens examples/hello.adb
```

Run smoke tests:

```sh
bash tests/smoke.sh
```

The parser currently supports only a documented initial subset of procedure compilation units. It does not yet implement the complete Ada grammar, semantic analysis, code generation, or execution.

## Development

See [docs/ROADMAP.md](docs/ROADMAP.md), [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), and [CONTRIBUTING.md](CONTRIBUTING.md).

## Conformance

ACATS is a compiler validation suite, not an implementation. Follow the official ACATS documentation and applicable usage terms. Store test outcomes with compiler revision, toolchain version, host environment, test identity, command, exit status, and logs. A successful subset run is not proof of full Ada conformance.

## License

No project license has been selected yet. Until a license is added, all rights are reserved. Do not assume that this repository or third-party test materials are freely reusable.

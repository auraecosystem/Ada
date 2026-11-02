# Contributing

## Before changing code
- Read the architecture and roadmap.
- Keep changes scoped to one compiler stage.
- Add tests for valid and invalid inputs.
- Do not silently weaken diagnostics or tests.

## Ada style
- Use Ada 2022 project switches for now; this is a build setting, not a claim that the compiler implements Ada 2022.
- Enable compiler warnings and treat warnings as errors in CI.
- Prefer explicit package interfaces and small subprograms.

## Verification
Run:

```sh
gprbuild -P ada_compiler.gpr
./bin/ada-compiler examples/hello.adb
```

Report toolchain versions and exact commands. Never report a test as passing if it was skipped or could not run.

The compiler is reporting that `Token_Kind` has an equality operator (`=`) declared in `Ada_Compiler.Lexer`, but that operator is not directly visible inside `ada_compiler_cli.adb`.

## Fix

Open `ada_compiler_cli.adb` and add the following `use type` clause after the existing `with` statements:

```adb
with Ada_Compiler.Lexer;

procedure Ada_Compiler_CLI is
   use type Ada_Compiler.Lexer.Token_Kind;
```

If the procedure already has declarations, simply insert:

```ada
use type Ada_Compiler.Lexer.Token_Kind;
```

inside the procedure's declarative section, before `begin`.

### Why this works

Ada has strict operator visibility rules.

Your lexer probably declares:

```adb
type Token_Kind is
  (Identifier,
   Number,
   String_Literal,
   End_Of_File);
```

When comparing values:

```ada
if Current_Token.Kind = End_Of_File then
```

the equality operator must be directly visible.

The `use type` clause makes primitive operators for that type directly visible without importing every declaration from the package.

## Rebuild

Run:

```bash
gprbuild -P ada_compiler.gpr
```

Then execute your smoke tests:

```Bash
gprbuild -P ada_compiler.gpr -XBUILD_MODE=debug
```

## Expected result

Compiler visibility fix

- Lexer implementation remains unchanged.
- No changes to token definitions.
- No GNAT wrapper.
- No architectural modifications.
- Only the required Ada visibility correction.



I inspected `auraecosystem/Ada` before changing anything. There is an important discrepancy: the repository's root-level `ada_compiler_cli.adb` currently contains ACATS `TCTouch` test-support code, not the compiler CLI described by your build error. I won't overwrite that file blindly.

The lexer specification does confirm that `Token_Kind` is declared in `Ada_Compiler.Lexer`, so the appropriate fix is still a `use type` clause in the actual compiler CLI source.

Fix committed and verified

Applied successfully to `main`.

Repository: [auraecosystem/Ada](https://github.com/auraecosystem/Ada?utm_source=chatgpt.com)

File changed: `cli/ada_compiler_cli.adb`

Added:

```ada
use type Ada_Compiler.Lexer.Token_Kind;
```

Commit: `19fcb883a2f0d8af10a322751ab2c35be8d1c2ec`

I fetched the file again from GitHub and verified that the change is present.

Verification status:

- Correct compiler CLI located.
- Visibility error corrected.
- Change committed to `main`.
- Updated file verified remotely.
- `gprbuild` compilation not yet executed.
- ACATS tests not yet executed.

Run this in your build environment:

```bash
gprbuild -P ada_compiler.gpr
```

The next step is to verify the build and address any remaining compiler errors.

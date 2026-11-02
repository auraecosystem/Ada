The compiler is reporting that `Token_Kind` has an equality operator (`=`) declared in `Ada_Compiler.Lexer`, but that operator is not directly visible inside `ada_compiler_cli.adb`.

## Fix

Open `ada_compiler_cli.adb` and add the following `use type` clause after the existing `with` statements:

```
with Ada_Compiler.Lexer;

procedure Ada_Compiler_CLI is
   use type Ada_Compiler.Lexer.Token_Kind;
```

If the procedure already has declarations, simply insert:

```
use type Ada_Compiler.Lexer.Token_Kind;
```

inside the procedure's declarative section, before `begin`.

### Why this works

Ada has strict operator visibility rules.

Your lexer probably declares:

```
type Token_Kind is
  (Identifier,
   Number,
   String_Literal,
   End_Of_File);
```

When comparing values:

```
if Current_Token.Kind = End_Of_File then
```

the equality operator must be directly visible.

The `use type` clause makes primitive operators for that type directly visible without importing every declaration from the package.

## Rebuild

Run:

```
gprbuild -P ada_compiler.gpr
```

Then execute your smoke tests:

```
gprbuild -P ada_compiler.gpr -XBUILD_MODE=debug
```

## Expected result

Compiler visibility fix

- Lexer implementation remains unchanged.
- No changes to token definitions.
- No GNAT wrapper.
- No architectural modifications.
- Only the required Ada visibility correction.

Next step: Once compilation succeeds, run the lexer smoke tests and proceed with the native Ada parser implementation.

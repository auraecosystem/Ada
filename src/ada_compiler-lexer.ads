with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;

package Ada_Compiler.Lexer is
   pragma Elaborate_Body;

   type Token_Kind is
     (Identifier,
      Integer_Literal,
      String_Literal,
      Character_Literal,
      Punctuation,
      End_Of_Input,
      Invalid);

   type Token is record
      Kind   : Token_Kind := Invalid;
      Lexeme : Ada.Strings.Unbounded.Unbounded_String;
      Offset : Natural := 0;
   end record;

   package Token_Lists is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => Token);

   function Tokenize (Source : String) return Token_Lists.Vector;
end Ada_Compiler.Lexer;

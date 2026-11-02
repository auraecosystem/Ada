with Ada.Characters.Handling;
with Ada.Strings.Unbounded;

package body Ada_Compiler.Lexer is
   use Ada.Strings.Unbounded;

   function Tokenize (Source : String) return Token_Lists.Vector is
      Result : Token_Lists.Vector;
      I      : Integer := Source'First;

      procedure Add
        (Kind : Token_Kind; First : Integer; Last : Integer) is
         Value : Unbounded_String;
      begin
         if Last >= First then
            Value := To_Unbounded_String (Source (First .. Last));
         else
            Value := Null_Unbounded_String;
         end if;

         Result.Append
           ((Kind   => Kind,
             Lexeme => Value,
             Offset => Natural (First - Source'First)));
      end Add;

   begin
      while I <= Source'Last loop
         if Source (I) = ' ' or else Source (I) = Character'Val (9)
           or else Source (I) = Character'Val (10)
           or else Source (I) = Character'Val (13)
         then
            I := I + 1;

         elsif Source (I) = '-' and then I < Source'Last
           and then Source (I + 1) = '-'
         then
            exit;

         elsif Ada.Characters.Handling.Is_Letter (Source (I))
         then
            declare
               First : constant Integer := I;
            begin
               I := I + 1;
               while I <= Source'Last
                 and then
                   (Ada.Characters.Handling.Is_Alphanumeric (Source (I))
                    or else Source (I) = '_')
               loop
                  I := I + 1;
               end loop;
               Add (Identifier, First, I - 1);
            end;

         elsif Ada.Characters.Handling.Is_Digit (Source (I)) then
            declare
               First : constant Integer := I;
            begin
               I := I + 1;
               while I <= Source'Last
                 and then
                   (Ada.Characters.Handling.Is_Alphanumeric (Source (I))
                    or else Source (I) = '_')
               loop
                  I := I + 1;
               end loop;
               Add (Integer_Literal, First, I - 1);
            end;

         else
            Add (Punctuation, I, I);
            I := I + 1;
         end if;
      end loop;

      Result.Append
        ((Kind   => End_Of_Input,
          Lexeme => Null_Unbounded_String,
          Offset => Natural (Source'Length)));
      return Result;
   end Tokenize;
end Ada_Compiler.Lexer;

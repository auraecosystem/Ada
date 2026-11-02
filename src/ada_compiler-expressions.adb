with Ada_Compiler.Lexer;
with Ada.Characters.Handling;

package body Ada_Compiler.Expressions is
   use Ada.Strings.Unbounded;
   use type Ada_Compiler.Lexer.Token_Kind;

   function Parse (Source : String) return Parse_Result is
      Tokens : constant Ada_Compiler.Lexer.Token_Lists.Vector :=
        Ada_Compiler.Lexer.Tokenize (Source);
      Result : Parse_Result;
      Cursor : Positive := 1;

      function Current return Ada_Compiler.Lexer.Token is
      begin
         return Tokens (Cursor);
      end Current;

      function Text return String is
      begin
         return To_String (Current.Lexeme);
      end Text;

      function Lower_Text return String is
      begin
         return Ada.Characters.Handling.To_Lower (Text);
      end Lower_Text;

      function At_Punctuation (Value : String) return Boolean is
      begin
         return Current.Kind = Ada_Compiler.Lexer.Punctuation
           and then Text = Value;
      end At_Punctuation;

      function At_Word (Value : String) return Boolean is
      begin
         return Current.Kind = Ada_Compiler.Lexer.Identifier
           and then Lower_Text = Value;
      end At_Word;

      procedure Advance is
      begin
         if Current.Kind /= Ada_Compiler.Lexer.End_Of_Input then
            Cursor := Cursor + 1;
         end if;
      end Advance;

      procedure Add_Diagnostic (Message : String) is
      begin
         Result.Diagnostics.Append
           (Diagnostic'(Message => To_Unbounded_String (Message),
                        Offset => Current.Offset));
      end Add_Diagnostic;

      function Add_Node
        (Kind : Expression_Kind;
         Value : String;
         First_Offset, Last_Offset : Natural) return Positive
      is
      begin
         Result.Nodes.Append
           (Expression_Node'
              (Kind => Kind,
               Value => To_Unbounded_String (Value),
               First_Offset => First_Offset,
               Last_Offset => Last_Offset,
               Parent_Index => 0));
         return Positive (Result.Nodes.Length);
      end Add_Node;

      procedure Set_Parent (Child, Parent : Positive) is
         Item : Expression_Node := Result.Nodes (Child);
      begin
         Item.Parent_Index := Parent;
         Result.Nodes.Replace_Element (Child, Item);
      end Set_Parent;

      function Precedence return Natural is
      begin
         if At_Word ("or") or else At_Word ("xor") then
            return 1;
         elsif At_Word ("and") then
            return 2;
         elsif At_Punctuation ("=") or else At_Punctuation ("/=")
           or else At_Punctuation ("<") or else At_Punctuation ("<=")
           or else At_Punctuation (">") or else At_Punctuation (">=")
         then
            return 3;
         elsif At_Punctuation ("+") or else At_Punctuation ("-")
           or else At_Punctuation ("&")
         then
            return 4;
         elsif At_Punctuation ("*") or else At_Punctuation ("/")
           or else At_Word ("mod") or else At_Word ("rem")
         then
            return 5;
         elsif At_Punctuation ("**") then
            return 6;
         else
            return 0;
         end if;
      end Precedence;

      function Parse_Expression (Minimum : Natural) return Positive;

      function Parse_Primary return Positive is
         First : constant Natural := Current.Offset;
         Op    : Unbounded_String;
         Child : Positive;
         Node  : Positive;
      begin
         if At_Punctuation ("+") or else At_Punctuation ("-")
           or else At_Word ("not")
         then
            Op := Current.Lexeme;
            Advance;
            Child := Parse_Expression (6);
            Node := Add_Node
              (Unary_Expression, To_String (Op), First,
               Result.Nodes (Child).Last_Offset);
            Set_Parent (Child, Node);
            return Node;

         elsif Current.Kind = Ada_Compiler.Lexer.Identifier then
            Node := Add_Node
              (Identifier_Expression, Text, First,
               First + Natural (Length (Current.Lexeme)) - 1);
            Advance;
            return Node;

         elsif Current.Kind = Ada_Compiler.Lexer.Integer_Literal
           or else Current.Kind = Ada_Compiler.Lexer.String_Literal
           or else Current.Kind = Ada_Compiler.Lexer.Character_Literal
         then
            Node := Add_Node
              (Literal_Expression, Text, First,
               First + Natural (Length (Current.Lexeme)) - 1);
            Advance;
            return Node;

         elsif At_Punctuation ("(") then
            Advance;
            Child := Parse_Expression (1);
            if not At_Punctuation (")") then
               Add_Diagnostic ("expected ')' to close expression");
            else
               Advance;
            end if;
            Node := Add_Node
              (Parenthesized_Expression, "()", First,
               Result.Nodes (Child).Last_Offset);
            Set_Parent (Child, Node);
            return Node;
         else
            Add_Diagnostic ("expected expression operand");
            return Add_Node
              (Literal_Expression, "<missing>", First, First);
         end if;
      end Parse_Primary;

      function Parse_Expression (Minimum : Natural) return Positive is
         Left  : Positive := Parse_Primary;
         Right : Positive;
         Node  : Positive;
         Op    : Unbounded_String;
         Prec  : Natural;
         First : Natural;
         Last  : Natural;
         Next_Minimum : Natural;
      begin
         loop
            Prec := Precedence;
            exit when Prec < Minimum or else Prec = 0;

            Op := Current.Lexeme;
            Advance;
            Next_Minimum := (if To_String (Op) = "**" then Prec else Prec + 1);
            Right := Parse_Expression (Next_Minimum);
            First := Result.Nodes (Left).First_Offset;
            Last := Result.Nodes (Right).Last_Offset;
            Node := Add_Node
              (Binary_Expression, To_String (Op), First, Last);
            Set_Parent (Left, Node);
            Set_Parent (Right, Node);
            Left := Node;
         end loop;
         return Left;
      end Parse_Expression;

   begin
      if Current.Kind = Ada_Compiler.Lexer.End_Of_Input then
         Add_Diagnostic ("empty expression");
         return Result;
      end if;

      Result.Root_Index := Parse_Expression (1);
      if Current.Kind /= Ada_Compiler.Lexer.End_Of_Input then
         Add_Diagnostic ("unexpected token after expression");
      end if;
      Result.Success := Result.Diagnostics.Is_Empty;
      return Result;
   end Parse;
end Ada_Compiler.Expressions;

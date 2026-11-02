with Ada_Compiler.Lexer;
with Ada.Characters.Handling;

package body Ada_Compiler.Parser is
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

      function Word return String is
      begin
         return Ada.Characters.Handling.To_Lower
           (To_String (Current.Lexeme));
      end Word;

      function At_Word (Value : String) return Boolean is
      begin
         return Current.Kind = Ada_Compiler.Lexer.Identifier
           and then Word = Value;
      end At_Word;

      function At_Punctuation (Value : String) return Boolean is
      begin
         return Current.Kind = Ada_Compiler.Lexer.Punctuation
           and then To_String (Current.Lexeme) = Value;
      end At_Punctuation;

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
                        Offset  => Current.Offset));
      end Add_Diagnostic;

      procedure Add_Node
        (Kind : Node_Kind;
         Name : String;
         First_Offset, Last_Offset : Natural;
         Parent_Index : Natural) is
      begin
         Result.Nodes.Append
           (Node'(Kind         => Kind,
                  Name         => To_Unbounded_String (Name),
                  Span         => (First_Offset => First_Offset,
                                   Last_Offset  => Last_Offset),
                  Parent_Index => Parent_Index));
      end Add_Node;

      procedure Expect_Punctuation (Value : String) is
      begin
         if At_Punctuation (Value) then
            Advance;
         else
            Add_Diagnostic ("expected '" & Value & "'");
         end if;
      end Expect_Punctuation;

      procedure Parse_Context_Clause is
         First : constant Natural := Current.Offset;
         Name  : Unbounded_String;
      begin
         Advance; -- with
         if Current.Kind /= Ada_Compiler.Lexer.Identifier then
            Add_Diagnostic ("expected library unit name after with");
            return;
         end if;

         Append (Name, To_String (Current.Lexeme));
         Advance;
         while At_Punctuation (".") loop
            Advance;
            if Current.Kind = Ada_Compiler.Lexer.Identifier then
               Append (Name, ".");
               Append (Name, To_String (Current.Lexeme));
               Advance;
            else
               Add_Diagnostic ("expected identifier after '.'");
               exit;
            end if;
         end loop;
         Expect_Punctuation (";");
         Add_Node
           (Context_Clause, To_String (Name), First,
            Tokens (Positive'Max (1, Cursor - 1)).Offset, 1);
      end Parse_Context_Clause;

      procedure Parse_Statement (Body_Index : Natural) is
         First      : constant Natural := Current.Offset;
         Last       : Natural := First;
         Name       : Unbounded_String;
         Kind       : Node_Kind := Other_Statement;
         Has_Assign : Boolean := False;
         Has_Call   : Boolean := False;
      begin
         if At_Word ("null") then
            Kind := Null_Statement;
            Append (Name, "null");
         elsif Current.Kind = Ada_Compiler.Lexer.Identifier then
            Append (Name, To_String (Current.Lexeme));
         end if;

         while Current.Kind /= Ada_Compiler.Lexer.End_Of_Input
           and then not At_Word ("end")
         loop
            if At_Punctuation (";") then
               Last := Current.Offset;
               Advance;
               if Kind /= Null_Statement then
                  if Has_Assign then
                     Kind := Assignment_Statement;
                  elsif Has_Call then
                     Kind := Procedure_Call;
                  end if;
               end if;
               Add_Node (Kind, To_String (Name), First, Last, Body_Index);
               return;
            elsif At_Punctuation (":=") then
               Has_Assign := True;
            elsif At_Punctuation ("(") then
               Has_Call := True;
            end if;
            Last := Current.Offset;
            Advance;
         end loop;

         Add_Diagnostic ("expected ';' after statement");
         Add_Node (Kind, To_String (Name), First, Last, Body_Index);
      end Parse_Statement;

      procedure Parse_Subprogram_Body is
         First      : constant Natural := Current.Offset;
         Unit_Name  : Unbounded_String;
         Saw_Is     : Boolean := False;
         Body_Index : Natural := 0;
      begin
         Advance; -- procedure
         if Current.Kind /= Ada_Compiler.Lexer.Identifier then
            Add_Diagnostic ("expected procedure name");
            return;
         end if;

         Unit_Name := Current.Lexeme;
         Advance;

         -- Parameter profiles and declarations are deferred to later
         -- grammar increments; scan to the body introducer for now.
         while Current.Kind /= Ada_Compiler.Lexer.End_Of_Input
           and then not At_Word ("is")
           and then not At_Word ("begin")
         loop
            Advance;
         end loop;

         if At_Word ("is") then
            Saw_Is := True;
            Advance;
            while Current.Kind /= Ada_Compiler.Lexer.End_Of_Input
              and then not At_Word ("begin")
            loop
               Advance;
            end loop;
         end if;

         if not Saw_Is then
            Add_Diagnostic ("expected 'is' before procedure body");
            return;
         end if;

         if not At_Word ("begin") then
            Add_Diagnostic ("expected 'begin' in procedure body");
            return;
         end if;
         Advance;

         Add_Node
           (Subprogram_Body, To_String (Unit_Name), First, Current.Offset, 1);
         Body_Index := Natural (Result.Nodes.Length);

         while Current.Kind /= Ada_Compiler.Lexer.End_Of_Input
           and then not At_Word ("end")
         loop
            Parse_Statement (Body_Index);
         end loop;

         if not At_Word ("end") then
            Add_Diagnostic ("expected 'end' for procedure body");
            return;
         end if;
         Advance;

         if Current.Kind = Ada_Compiler.Lexer.Identifier
           and then not At_Punctuation (";")
         then
            if Ada.Characters.Handling.To_Lower
              (To_String (Current.Lexeme)) /=
                Ada.Characters.Handling.To_Lower (To_String (Unit_Name))
            then
               Add_Diagnostic ("end name does not match procedure name");
            end if;
            Advance;
         end if;
         Expect_Punctuation (";");
      end Parse_Subprogram_Body;

   begin
      --  The root is inserted first so every subsequent parent index is
      --  stable and points to an already-created node.
      Add_Node
        (Compilation_Unit, "", 0, Natural (Source'Length), 0);

      while At_Word ("with") loop
         Parse_Context_Clause;
      end loop;

      if At_Word ("procedure") then
         Parse_Subprogram_Body;
      else
         Add_Diagnostic ("expected a procedure compilation unit");
      end if;

      if Current.Kind /= Ada_Compiler.Lexer.End_Of_Input then
         Add_Diagnostic ("unexpected tokens after compilation unit");
      end if;

      Result.Success := Result.Diagnostics.Is_Empty;
      return Result;
   end Parse;
end Ada_Compiler.Parser;

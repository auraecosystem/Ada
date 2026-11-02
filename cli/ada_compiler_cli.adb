with Ada.Command_Line;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada_Compiler.Lexer;
with Ada_Compiler.Parser;

procedure Ada_Compiler_CLI is
   use Ada.Text_IO;
   use Ada.Strings.Unbounded;
   use type Ada_Compiler.Lexer.Token_Kind;

   File       : File_Type;
   Source     : Unbounded_String;
   Token_Mode : Boolean := False;
   File_Name  : Unbounded_String;
begin
   if Ada.Command_Line.Argument_Count = 1 then
      File_Name := To_Unbounded_String (Ada.Command_Line.Argument (1));
   elsif Ada.Command_Line.Argument_Count = 2
     and then Ada.Command_Line.Argument (1) = "--tokens"
   then
      Token_Mode := True;
      File_Name := To_Unbounded_String (Ada.Command_Line.Argument (2));
   else
      Put_Line ("usage: ada-compiler [--tokens] <source-file>");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      return;
   end if;

   Open (File, In_File, To_String (File_Name));
   while not End_Of_File (File) loop
      Append (Source, Get_Line (File));
      Append (Source, Character'Val (10));
   end loop;
   Close (File);

   if Token_Mode then
      declare
         Tokens : constant Ada_Compiler.Lexer.Token_Lists.Vector :=
           Ada_Compiler.Lexer.Tokenize (To_String (Source));
      begin
         for Item of Tokens loop
            if Item.Kind /= Ada_Compiler.Lexer.End_Of_Input then
               Put_Line
                 (Ada_Compiler.Lexer.Token_Kind'Image (Item.Kind)
                  & " " & To_String (Item.Lexeme));
            end if;
         end loop;
      end;
   else
      declare
         Parsed : constant Ada_Compiler.Parser.Parse_Result :=
           Ada_Compiler.Parser.Parse (To_String (Source));
      begin
         for Item of Parsed.Nodes loop
            Put_Line
              (Ada_Compiler.Parser.Node_Kind'Image (Item.Kind)
               & (if Length (Item.Name) = 0 then ""
                  else " " & To_String (Item.Name)));
         end loop;

         for Item of Parsed.Diagnostics loop
            Put_Line
              ("error at" & Natural'Image (Item.Offset) & ": "
               & To_String (Item.Message));
         end loop;

         if not Parsed.Success then
            Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
         end if;
      end;
   end if;
exception
   when others =>
      if Is_Open (File) then
         Close (File);
      end if;
      Put_Line ("error: unable to process source file");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Ada_Compiler_CLI;

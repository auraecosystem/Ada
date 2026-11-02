with Ada.Command_Line;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada_Compiler.Lexer;

procedure Ada_Compiler_CLI is
   use Ada.Text_IO;
   use Ada.Strings.Unbounded;

   File : File_Type;
begin
   if Ada.Command_Line.Argument_Count /= 1 then
      Put_Line ("usage: ada-compiler <source-file>");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      return;
   end if;

   Open (File, In_File, Ada.Command_Line.Argument (1));
   while not End_Of_File (File) loop
      declare
         Line   : constant String := Get_Line (File);
         Tokens : constant Ada_Compiler.Lexer.Token_Lists.Vector :=
           Ada_Compiler.Lexer.Tokenize (Line);
      begin
         for Item of Tokens loop
            if Item.Kind /= Ada_Compiler.Lexer.End_Of_Input then
               Put_Line
                 (Ada_Compiler.Lexer.Token_Kind'Image (Item.Kind)
                  & " " & To_String (Item.Lexeme));
            end if;
         end loop;
      end;
   end loop;
   Close (File);
exception
   when others =>
      if Is_Open (File) then
         Close (File);
      end if;
      Put_Line ("error: unable to process source file");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Ada_Compiler_CLI;

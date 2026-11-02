with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

package Ada_Compiler.Parser is
   type Node_Kind is
     (Compilation_Unit,
      Context_Clause,
      Subprogram_Body,
      Null_Statement,
      Procedure_Call,
      Assignment_Statement,
      Other_Statement);

   type Source_Span is record
      First_Offset : Natural := 0;
      Last_Offset  : Natural := 0;
   end record;

   --  Parent_Index is zero only for the compilation-unit root. All other
   --  nodes refer to an earlier node in Parse_Result.Nodes.
   type Node is record
      Kind         : Node_Kind := Other_Statement;
      Name         : Ada.Strings.Unbounded.Unbounded_String;
      Span         : Source_Span;
      Parent_Index : Natural := 0;
   end record;

   package Node_Lists is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => Node);

   type Diagnostic is record
      Message : Ada.Strings.Unbounded.Unbounded_String;
      Offset  : Natural := 0;
   end record;

   package Diagnostic_Lists is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => Diagnostic);

   type Parse_Result is record
      Nodes       : Node_Lists.Vector;
      Diagnostics : Diagnostic_Lists.Vector;
      Success     : Boolean := False;
   end record;

   function Parse (Source : String) return Parse_Result;
end Ada_Compiler.Parser;

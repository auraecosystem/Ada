with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

package Ada_Compiler.Expressions is
   type Expression_Kind is
     (Identifier_Expression,
      Literal_Expression,
      Unary_Expression,
      Binary_Expression,
      Parenthesized_Expression);

   type Expression_Node is record
      Kind         : Expression_Kind := Literal_Expression;
      Value        : Ada.Strings.Unbounded.Unbounded_String;
      First_Offset : Natural := 0;
      Last_Offset  : Natural := 0;
      Parent_Index : Natural := 0;
   end record;

   package Expression_Lists is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => Expression_Node);

   type Diagnostic is record
      Message : Ada.Strings.Unbounded.Unbounded_String;
      Offset  : Natural := 0;
   end record;

   package Diagnostic_Lists is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => Diagnostic);

   type Parse_Result is record
      Nodes       : Expression_Lists.Vector;
      Diagnostics : Diagnostic_Lists.Vector;
      Root_Index  : Natural := 0;
      Success     : Boolean := False;
   end record;

   function Parse (Source : String) return Parse_Result;
end Ada_Compiler.Expressions;

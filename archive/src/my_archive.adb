with Ada.Text_IO;                       use Ada.Text_IO;
with Ada.Float_Text_IO;                 use Ada.Float_Text_IO;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

package body My_Archive is
   function Archive_it (A: in out Float_Vector) return Float_Vector is
      Tmp : Float := 5.0;
      I: Integer := 1;
      Output_file : File_Type;
   begin
      while True loop
         delay 1.0;
         begin
         Open (File => Output_file,Mode => Append_File,Name => "archive.csv");
         exception
           when Name_Error =>
               Create (File => Output_file, Mode => Append_File, Name => "archive.csv");
         end;
         for I in A'First .. A'Last loop
            Put(File => Output_file,Item => A(I),Fore => 5, Aft => 3, Exp => 0);
            Put(Item => A(I),Fore => 5, Aft => 3, Exp => 0);
            Put(Output_file,";");
         end loop;
         Put_Line(Output_file,"");
         Close (Output_file);
      end loop;
      return A;
  end Archive_it;
end My_Archive;

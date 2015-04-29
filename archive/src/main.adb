with My_Archive; use My_Archive;
with Ada.Text_IO, Ada.Float_Text_IO; use Ada.Text_IO, Ada.Float_Text_IO;
procedure Main is
   test : Float_Vector (1 .. 5) := (3.5,2.1,1.5,2.05,-7.13);
begin
   test := My_Archive.Archive_it(test);
   Ada.Text_IO.Put_Line("Hello");
end Main;

with My_Archive; use My_Archive;
with Ada.Text_IO, Ada.Float_Text_IO; use Ada.Text_IO, Ada.Float_Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with ValueTypes; use ValueTypes;
with Ada.Calendar;             use Ada.Calendar;
with Ada.Calendar.Formatting;  use Ada.Calendar.Formatting;
with Ada.Calendar.Time_Zones;  use Ada.Calendar.Time_Zones;
with Ada.Text_IO;              use Ada.Text_IO;

procedure Main is
test : TValue :=
     (value => 0.7,
      timeStamp => Ada.Calendar.Clock,
      status => (Valid => False, Unknown => True)
     );
begin
   My_Archive.Archive_it(test);
   Ada.Text_IO.Put_Line("Hello");
end Main;
--comment

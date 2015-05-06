with Ada.Text_IO;                       use Ada.Text_IO;
with Ada.Float_Text_IO;                 use Ada.Float_Text_IO;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with ValueTypes; use ValueTypes;
with Ada.Float_Text_IO;                 use Ada.Float_Text_IO;
with Ada.Long_Float_Text_IO;            use Ada.Long_Float_Text_IO;
with Ada.Calendar; use Ada.Calendar;
with Ada.Calendar.Formatting; use Ada.Calendar.Formatting;
with Ada.Calendar.Time_Zones; use Ada.Calendar.Time_Zones;
with Ada.Real_Time; use Ada.Real_Time;

package body My_Archive is
   procedure Archive_it (A: in out TValue; fname: in out String) is
      Tmp : Float := 5.0;
      Output_file : File_Type;
   begin
         begin
         Open (File => Output_file,Mode => Append_File,Name => fname);
         exception
           when Name_Error =>
               Create (File => Output_file, Mode => Append_File, Name => fname);
         end;
         Put(File => Output_file,Item => A.value ,Fore => 5, Aft => 3, Exp => 0);
         Put(Output_file,";");
         Put(File => Output_file,Item => Image(Date => A.timeStamp, Time_Zone => Ada.Calendar.Time_Zones.UTC_Time_Offset));
         Put(Output_file,";");
         if  A.status(Valid) then
            Put(File => Output_file,Item => "Valid");
         else
            Put(File => Output_file,Item => "Unknown");
         end if;
         Put_Line(Output_file,"");
         Close (Output_file);
  end Archive_it;
end My_Archive;

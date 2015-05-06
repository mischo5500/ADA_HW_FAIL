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
   procedure Archive_it (A: in out TValue) is
      Tmp : Float := 5.0;
      My_Year: Integer := 0;
      My_Month: Integer := 0;
      My_Day: Integer := 0;
      My_Hour: Integer := 0;
      My_Minute: Integer := 0;
      My_Seconds: Integer := 0;
      Sub_Second: Integer := 0;
      Leap_Second: Boolean := False;
      Time_Zone: Integer := 0;
      Output_file : File_Type;

      myData : Ada.Real_Time.Time_Span := Ada.Real_Time.Time_Span_Zero;
      use type Ada.Real_Time.Time_Span;
   begin
      while True loop
         delay 1.0;
         begin
         Open (File => Output_file,Mode => Append_File,Name => "archive.csv");
         exception
           when Name_Error =>
               Create (File => Output_file, Mode => Append_File, Name => "archive.csv");
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
      end loop;
  end Archive_it;
end My_Archive;

with Ada.Real_Time; use Ada.Real_Time;
with Ada.Strings.Bounded;
with Ada.Calendar;             use Ada.Calendar;
with Ada.Calendar.Formatting;  use Ada.Calendar.Formatting;
with Ada.Calendar.Time_Zones;  use Ada.Calendar.Time_Zones;
with Ada.Text_IO;              use Ada.Text_IO;

package ValueTypes is

  type TValueStatus_Elm is (Valid, Unknown);
  type TValueStatus is array (TValueStatus_Elm'Range) of Boolean;
  for TValueStatus'Component_Size use 1;

  -- Hodnota
  type TValue is record
    --
    value : Long_Float;
    -- hodnota

    timeStamp : Ada.Calendar.Time;
    -- casova znacka

    status : TValueStatus;
    -- priznak platnosti
  end record;
  --
  --unknownValue : constant TValue :=
    -- (value => 0.0,
     -- timeStamp => Time_First,
      --status => (Valid => False, Unknown => True)
   --  );
  validValue : constant TValue :=
   (value => 0.0,
      timeStamp => Ada.Calendar.Clock,
      status => (Valid => True, Unknown => False)
   );
  --
  VALUE_NAME_LENGTH : constant := 32;
  --
  package ValueName_Pkg is new Ada.Strings.Bounded.Generic_Bounded_Length (
                                                                           VALUE_NAME_LENGTH);
  use ValueName_Pkg;
  -- meno hodnoty
  subtype TValueName is ValueName_Pkg.Bounded_String;

  CLIENT_NAME_LENGTH : constant := 32;
  package ClientName_Pkg is new Ada.Strings.Bounded.Generic_Bounded_Length (
                                                                            CLIENT_NAME_LENGTH);
  use ClientName_Pkg;
  -- meno hodnoty
  subtype TClientName is ClientName_Pkg.Bounded_String;

end ValueTypes;

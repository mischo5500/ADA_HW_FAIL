with Ada.Text_IO;		use Ada.Text_IO;
with Ada.Float_Text_IO;                 use Ada.Float_Text_IO;
with Ada.Long_Float_Text_IO;            use Ada.Long_Float_Text_IO;

package body Client_Msgs is

  ------------
  -- Action --
  ------------

  procedure Action (Self : in CConnectMessage) is
  begin
    --  Generated stub: replace with real body!
    pragma Compile_Time_Warning (True, "Action unimplemented");
    raise Program_Error;
  end Action;

  ------------
  -- Action --
  ------------

  procedure Action (Self : in CAttachValue) is
  begin
    --  Generated stub: replace with real body!
    pragma Compile_Time_Warning (True, "Action unimplemented");
    raise Program_Error;
  end Action;

  ------------
  -- Action --
  ------------

  procedure Action (Self : in CChangeValue) is
  begin
    Put(ValueName_Pkg.To_String(Self.valueName)& " = ");
    Put(Item =>Self.value.value, Fore => 5, Aft => 3, Exp => 0);
    Put_Line("");
    if(ValueName_Pkg.To_String(Self.valueName) = "ZiadanavyskaHladiny")then
      Put_Line("Vyska");
    --elsif(Name = "sophomore")then
    --  return 2;
    else
      Put_Line("Nieco ine");
    end if;
  end Action;

  ------------
  -- Action --
  ------------

  procedure Action (Self : in CSetValue) is
  begin
    --  Generated stub: replace with real body!
    pragma Compile_Time_Warning (True, "Action unimplemented");
    raise Program_Error;
  end Action;

end Client_Msgs;

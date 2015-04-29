with Ada.Text_IO;			use Ada.Text_IO;
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
      Put_Line(ValueName_Pkg.To_String(Self.valueName) & " = " & Self.value.value'Img);
      Pritok := Self.value.value;
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

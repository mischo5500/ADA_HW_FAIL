with Ada.Text_IO;			use Ada.Text_IO;
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
      --Put_Line(ValueName_Pkg.To_String(Self.valueName) & " = " & Self.value.value'Img);
    if(ValueName_Pkg.To_String(Self.valueName) = "VyskaHladiny")then
        Hladina:=Self.value.value;
        --Put("Aktualna vyska: ");
        --Put(Item =>Hladina,Fore => 5, Aft => 3, Exp => 0);
        --Put_Line("");
    end if;
    if(ValueName_Pkg.To_String(Self.valueName) = "Pritok")then
        Pritok := Self.value.value;
        --Put("Pritok: ");
        --Put(Item =>Pritok,Fore => 5, Aft => 3, Exp => 0);
        --Put_Line("");
      end if;

     if(ValueName_Pkg.To_String(Self.valueName) = "Odtok")then
        Odtok := Self.value.value;
        --Put("Odtok: ");
        --Put(Item =>Odtok,Fore => 5, Aft => 3, Exp => 0);
        --Put_Line("");
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

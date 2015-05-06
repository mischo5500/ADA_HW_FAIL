pragma Ada_2005;
with Client;
with Connection;			use Connection;
with Client_Msgs;                       use Client_Msgs;
with Ada.Strings.Unbounded;		use Ada.Strings.Unbounded;
with ValueTypes;			use ValueTypes;
with Ada.Text_IO;			use Ada.Text_IO;
with GNAT.OS_Lib;
with Ada.Long_Float_Text_IO;            use Ada.Long_Float_Text_IO;

procedure Riadenie is
  c : Connection.TConnectionRef;
  bConnectionWasTerminated : Boolean;
  novy_pritok : Long_Long_Integer := 0;
begin
  Connection.GlobalInit;
  --
  c := Client.Connect("Riadenie", "172.16.1.116", 12345);
  if c /= notConnected then
    --
    declare
      msg_CPtr : CConnectMessage_CPtr := new CConnectMessage;
    begin
      msg_CPtr.clientName := ClientName_Pkg.To_Bounded_String("Riadenie");
      Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
    end;
    declare
      use Client_Msgs;
      msg_CPtr : CAttachValue_CPtr := new CAttachValue;
    begin
      msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("ZiadanavyskaHladiny");
      Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
    end;
    declare
      use Client_Msgs;
      msg_CPtr : CAttachValue_CPtr := new CAttachValue;
    begin
      msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("VyskaHladiny");
      Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
    end;
    --
    loop
      delay 1.0;
      --
      if(Hladina > ZiadanaHladina) then
         if(novy_pritok > 10) then
           novy_pritok := novy_pritok - 10;
         else
           novy_pritok := 0;
         end if;
      elsif(Hladina < ZiadanaHladina) then
            if(novy_pritok < 500) then
           novy_pritok := novy_pritok + 10;
         else
           novy_pritok := 500;
         end if;
      end if;
      declare
        msg_CPtr : CSetValue_CPtr := new CSetValue;
      begin
        msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("Pritok"); --vyska hladiny
        msg_CPtr.value := validValue;
        msg_CPtr.value.value := Long_Float(novy_pritok);
        Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
      end;
      --
    end loop;
    --
    Connection.Disconnect(c);
  else
    Put_Line("Connect failed.");
  end if;
  --
  GNAT.OS_Lib.OS_Exit(0);
  --
end Riadenie;

pragma Ada_2005;
with Client;
with Connection;			use Connection;
with Client_Msgs;
with Ada.Strings.Unbounded;		use Ada.Strings.Unbounded;
with ValueTypes;			use ValueTypes;
with Ada.Text_IO;			use Ada.Text_IO;
with GNAT.OS_Lib;

procedure Riadenie is
  c : Connection.TConnectionRef;
  bConnectionWasTerminated : Boolean;
  i : Long_Long_Integer := 0;
begin
  Connection.GlobalInit;
  --
  c := Client.Connect("Riadenie", "172.16.1.116", 12345);
  if c /= notConnected then
    --
    declare
      use Client_Msgs;
      msg_CPtr : CConnectMessage_CPtr := new CConnectMessage;
    begin
      msg_CPtr.clientName := ClientName_Pkg.To_Bounded_String("Riadenie");
      Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
    end;
    --
    loop
      delay 1.0;
      --
      i := i + 1;
      --
      declare
        use Client_Msgs;
        msg_CPtr : CSetValue_CPtr := new CSetValue;
      begin
        msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("Pritok"); --vyska hladiny
        msg_CPtr.value := validValue;
        msg_CPtr.value.value := Long_Float(i);
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

pragma Ada_2005;
with Client;
with Connection;			use Connection;
with Client_Msgs;                       use Client_Msgs;
with Ada.Strings.Unbounded;		use Ada.Strings.Unbounded;
with ValueTypes;			use ValueTypes;
with Ada.Text_IO;			use Ada.Text_IO;
with GNAT.OS_Lib;
with Ada.Long_Float_Text_IO;            use Ada.Long_Float_Text_IO;
with Ada.Calendar;

procedure Riadenie is
  c : Connection.TConnectionRef;
  bConnectionWasTerminated : Boolean;
  novy_pritok : Long_Float := 0.0;
  chyba : Long_Float := 0.0;
  integrovana_chyba : Long_Float := 0.0;
  akcna : Long_Float := 0.0;
  stara_chyba : Long_Float := 0.0;
  derivovana_chyba : Long_Float := 0.0;

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
      Hladina := 0;
    loop
      delay 1.0;
      chyba := ZiadanaHladina - Hladina;
      derivovana_chyba := chyba - stara_chyba;
      integrovana_chyba := integrovana_chyba + chyba;
      akcna := 0.8 * chyba + 0.6 * derivovana_chyba; --+ 0.6 * integrovana_chyba;
      novy_pritok := novy_pritok + akcna;
      stara_chyba := chyba;
      --
      if(novy_pritok < 0.0) then
          novy_pritok := 0.0;
      end if;
      if(novy_pritok > 200.0) then
          novy_pritok := 200.0;
      end if;
      declare
        msg_CPtr : CSetValue_CPtr := new CSetValue;
      begin
        msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("Pritok"); --vyska hladiny
        msg_CPtr.value := validValue;
        msg_CPtr.value.value := Long_Float(novy_pritok);
        msg_CPtr.value.timeStamp := Ada.Calendar.Clock;
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

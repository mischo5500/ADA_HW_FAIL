pragma Ada_2005;
with Client;
with Connection;			use Connection;
with Client_Msgs;
with ValueTypes;			use ValueTypes;
with Ada.Text_IO;			use Ada.Text_IO;
with GNAT.OS_Lib;
with Ada.Numerics.Float_Random;	use Ada.Numerics.Float_Random;
with Ada.Real_Time;		use Ada.Real_Time;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Float_Text_IO;                 use Ada.Float_Text_IO;
with Ada.Long_Float_Text_IO;            use Ada.Long_Float_Text_IO;
procedure Nadrz is
  c : Connection.TConnectionRef;
  bConnectionWasTerminated : Boolean;
   Rnd_Odtok : Generator;
   pom : Integer :=0;
begin
  Connection.GlobalInit;
  --
  c := Client.Connect("Nadrz", "172.16.1.116", 12345);
  if c /= notConnected then
    --
    declare
      use Client_Msgs;
      msg_CPtr : CConnectMessage_CPtr := new CConnectMessage; --informativna sprava

    begin
      msg_CPtr.clientName := ClientName_Pkg.To_Bounded_String("Nadrz");
      Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
    end;
    declare
      use Client_Msgs;
      msg_CPtr : CAttachValue_CPtr := new CAttachValue;
    begin
      msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("Pritok");
      Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
    end;
    --
    loop
      delay 1.0;
         --
         pom := pom + 1;
         if pom = 10 then
            Client_Msgs.Odtok := 10.0*Long_Float(Random(Rnd_Odtok));
            pom := 0;
         end if;
      --
      declare
        use Client_Msgs;
        msg_CPtr : CSetValue_CPtr := new CSetValue;
      begin
        msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("VyskaHladiny");
        msg_CPtr.value := validValue;
        msg_CPtr.value.timeStamp := Clock;
        msg_CPtr.value.value := Long_Float(hladina);
        Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated); --posle hodnotu
            Put("Pritok: ");
            Put(Item =>Pritok,Fore => 5, Aft => 3, Exp => 0);
            Put_Line("");
            Put("Hladina: ");
            Put(Item =>Hladina,Fore => 5, Aft => 3, Exp => 0);
            Put_Line("");
            Put("Odtok: ");
            Put(Item =>Odtok,Fore => 5, Aft => 3, Exp => 0);
            Put_Line("");
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
end Nadrz;


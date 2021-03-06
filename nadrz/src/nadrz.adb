pragma Ada_2005;
with Client;
with Connection;			use Connection;
with Client_Msgs;
use Client_Msgs;
with ValueTypes;			use ValueTypes;
with Ada.Text_IO;			use Ada.Text_IO;
with GNAT.OS_Lib;
with Ada.Numerics.Float_Random;	use Ada.Numerics.Float_Random;
with Ada.Real_Time;		use Ada.Real_Time;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Float_Text_IO;                 use Ada.Float_Text_IO;
with Ada.Long_Float_Text_IO;            use Ada.Long_Float_Text_IO;
with Ada.Calendar;

procedure Nadrz is
  c : Connection.TConnectionRef;
  bConnectionWasTerminated : Boolean;
  Rnd_Odtok : Generator;
   pom : Integer :=0; --pomocna premenna na pocitanie sekund
   vyskaHladaniny_TimeStamp : Time := Clock;
   vyskaHladaniny_TimeStamp2 : Time;
   dT: Duration;
   zmenaVysky : Long_Float := 0.0;
   h : Long_Float := 0.0; --pomocna premenna pri ratani Hladiny
begin
  Connection.GlobalInit;
  --
  c := Client.Connect("Nadrz", "172.16.1.116", 12345);
  if c /= notConnected then
    --
    declare
      msg_CPtr : CConnectMessage_CPtr := new CConnectMessage; --informativna sprava

    begin
      msg_CPtr.clientName := ClientName_Pkg.To_Bounded_String("Nadrz");
      Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
    end;
    declare
      msg_CPtr : CAttachValue_CPtr := new CAttachValue;
    begin
      msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("Pritok");
      Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
    end;
      --
    Odtok := 100.0*Long_Float(Random(Rnd_Odtok)); --pociatocne naplnenie odtoku
    loop
      delay 1.0;
         --
         vyskaHladaniny_TimeStamp2 := Clock;
         pom := pom + 1;
         if (pom = 10 and Hladina >= 0.0) then
            Client_Msgs.Odtok := 100.0*Long_Float(Random(Rnd_Odtok));
            pom := 0;
         end if;
         dT := To_Duration(vyskaHladaniny_TimeStamp2 - vyskaHladaniny_TimeStamp);
         vyskaHladaniny_TimeStamp := vyskaHladaniny_TimeStamp2;
         zmenaVysky := Long_Float(dT) * (Pritok - Odtok);
         h := Hladina + zmenaVysky;
         if h > 0.0 then
           Hladina := h;
         else
           Hladina := 0.0;
           --Odtok := 0.0;
         end if;
         --if Hladina < 0.0 then stare pocitanie odtoku
           -- Odtok := 0.0;
           -- Hladina := 0.0;
         --end --if;
        -- Hladina := Hladina + Pritok - Odtok;
      --
      declare
        msg_CPtr : CSetValue_CPtr := new CSetValue;
      begin
        msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("VyskaHladiny");
        msg_CPtr.value := validValue;
        msg_CPtr.value.timeStamp := Ada.Calendar.Clock;
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
      declare
        msg_CPtr : CSetValue_CPtr := new CSetValue;
      begin
        msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("Odtok");
        msg_CPtr.value := validValue;
        msg_CPtr.value.timeStamp := Ada.Calendar.Clock;
        msg_CPtr.value.value := Long_Float(Odtok);
        Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated); --posle hodnotu
      end;
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


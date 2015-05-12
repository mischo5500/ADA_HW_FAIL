pragma Ada_2005;
with Client;
with Connection;			use Connection;
with Client_Msgs;
--with Ada.Strings.Unbounded;		use Ada.Strings.Unbounded;
with ValueTypes;			use ValueTypes;
with Ada.Text_IO;			use Ada.Text_IO;
with GNAT.OS_Lib;
with Ada.Integer_Text_IO; use  Ada.Integer_Text_IO;
with Ada.Long_Float_Text_IO;            use Ada.Long_Float_Text_IO;
with Ada.Calendar;

procedure ShowConsole is
   c : Connection.TConnectionRef;
   bConnectionWasTerminated : Boolean;
   newSurfaceValue : Integer :=0;
begin
  Connection.GlobalInit;
  --
  c := Client.Connect("ShowConsole", "172.16.1.18", 12345);
  if c /= notConnected then
    --
    declare
      use Client_Msgs;
      msg_CPtr : CConnectMessage_CPtr := new CConnectMessage;
    begin
      msg_CPtr.clientName := ClientName_Pkg.To_Bounded_String("ShowConsole");
      Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
    end;
    --Attach na pritok
    declare
      use Client_Msgs;
      msg_CPtr : CAttachValue_CPtr := new CAttachValue;
    begin
      msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("Pritok");
      Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
    end;
    --Attach na Odtok
    declare
      use Client_Msgs;
      msg_CPtr : CAttachValue_CPtr := new CAttachValue;
    begin
      msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("Odtok");
      Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
    end;

    declare
      use Client_Msgs;
      msg_CPtr : CAttachValue_CPtr := new CAttachValue;
    begin
      msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("VyskaHladiny");
      Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
    end;
    --Attach na Ziadanu vysku hladiny "ZiadanavyskaHladiny"
    declare
      use Client_Msgs;
      msg_CPtr : CAttachValue_CPtr := new CAttachValue;
    begin
      msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("ZiadanavyskaHladiny");
      Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
    end;
    loop
      Put_Line("Menu:");
      Put_Line("1 - Zobrazenie vsetkych 4 velicin (pritok, odtok, vyska, ziadana vyska)");
      --Put_Line("2 - Zobrazenie pritoku");
      Put_Line("3 - Nastavit ziadanu vysku");
      Put_Line("h - help");
      Put_Line("e - end");
      declare
            line : String := Get_Line;

         begin

          if line'Length = 1 then
              exit when line(line'First) = 'e';
              if line(line'First) = 'h' then
                  Put_Line("Help ....");
               end if;

              if line(line'First) = '1' then
                  Put_Line("Pritok:");
                  Put_Line(Long_Float'Image(Client_Msgs.Pritok));
                  Put_Line("Odtok:");
                  Put_Line(Long_Float'Image(Client_Msgs.Odtok));
                  Put_Line("Vyska hladiny:");
                  Put_Line(Long_Float'Image(Client_Msgs.Hladina));
                  Put_Line("Ziadana vyska hladiny:");
                  Put_Line(Long_Float'Image(Client_Msgs.ZiadanaHladina));
               end if;
               if line(line'First) = '3' then

                     Put_Line("Enter new height of water level:");
                     get(newSurfaceValue);
                     declare
                        use Client_Msgs;
                        msg_CPtr : CSetValue_CPtr := new CSetValue;
                     begin
                        msg_CPtr.valueName := ValueName_Pkg.To_Bounded_String("ZiadanavyskaHladiny"); --vyska hladiny zadana
                        msg_CPtr.value := validValue;
                        msg_CPtr.value.value := Long_Float(newSurfaceValue);
                        Connection.SendMessage(c, CMessage_CPtr(msg_CPtr), bConnectionWasTerminated);
                     end;

               end if;
          end if;
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
end ShowConsole;

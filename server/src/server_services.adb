pragma Ada_2005;
with Ada.Text_IO; 		use Ada.Text_IO;
with Ada.Containers.Ordered_Maps;
with Ada.Unchecked_Deallocation;
with Client_Msgs;

-- ?!?!?!
pragma Warnings(Off);
with ValueTypes;
pragma Warnings(On);

use ValueTypes.ValueName_Pkg;


package body Server_Services is

  --
  type TNamedValue;
  type TNamedValue_Ptr is access TNamedValue;
  --
  type TConnectionInfo;
  type TConnectionInfo_Ptr is access TConnectionInfo;
  --
  package NamedValues_Pkg is new Ada.Containers.Ordered_Maps
     (Key_Type => TValueName,
      Element_Type => TNamedValue_Ptr);
  --
  package ConnectionInfo_Pkg is new Ada.Containers.Ordered_Maps
     (Key_Type => TConnectionRef,
      Element_Type => TConnectionInfo_Ptr);
  --
  type TNamedValue is limited record
    valueName : TValueName;
    currValue : TValue;
    clients   : ConnectionInfo_Pkg.Map;		-- zoznam zaujemcov (vytvarany cez AttachValue)
  end record;

  type TConnectionInfo is limited record
    connectionRef : TConnectionRef;
    values   : NamedValues_Pkg.Map;		-- zoznam hodnot o ktore ma zaujem (vytvarany cez AttachValue)
  end record;

  ---------------------------
  -- Server: Specification --
  ---------------------------

  protected Server is
    --
    procedure AttachValue
       (connectionRef : in TConnectionRef;
        valueName     : in TValueName);
    --
    procedure SetValue
       (connectionRef : in TConnectionRef;
        valueName     : in TValueName;
        value         : in TValue);
    --
    procedure ConnectionWasDied
       (connectionRef : in TConnectionRef);
    --
    procedure ConnectionWasEstablised
       (connectionRef : in TConnectionRef);
  private
    valuesMap : NamedValues_Pkg.Map;
    connectionsMap : ConnectionInfo_Pkg.Map;
  end Server;

  ----------------------------
  -- Server: Implementation --
  ----------------------------

  protected body Server is
    --
    procedure GetOrCreateNamedValue
       (valueName : in TValueName;
        namedValue_Ptr : out TNamedValue_Ptr)
    is
      use NamedValues_Pkg;
      --
      c : Cursor := Find(valuesMap, valueName);

      --
    begin
      --
      if c = No_Element then
        -- neexistuje => zalozim
        namedValue_Ptr := new TNamedValue'
           (valueName => valueName,
            currValue => unknownValue,
            clients   => ConnectionInfo_Pkg.Empty_Map);
        -- a zaradim do zoznamu
        Insert(valuesMap, valueName, namedValue_Ptr);
        --
      else -- existuje => vratim
        namedValue_Ptr := Element(c);
      end if;
      --
    end GetOrCreateNamedValue;
    --
    function GetConnectionInfo
       (connectionRef : in TConnectionRef)
        return TConnectionInfo_Ptr
    is
      use ConnectionInfo_Pkg;
      --
      c : Cursor := Find(connectionsMap, connectionRef);
      --
      connectionInfo_Ptr : TConnectionInfo_Ptr;
      --
    begin
      --
      if c = No_Element then
        -- neexistuje =>
        connectionInfo_Ptr := null;
        --
      else -- existuje => vratim
        connectionInfo_Ptr := Element(c);
      end if;
      --
      return connectionInfo_Ptr;
    end GetConnectionInfo;
    --
    procedure AttachValue
       (connectionRef : in TConnectionRef;
        valueName     : in TValueName)
    is
      use ConnectionInfo_Pkg, NamedValues_Pkg;
      --
      namedValue_Ptr : TNamedValue_Ptr;
      connectionInfo_Ptr : TConnectionInfo_Ptr := GetConnectionInfo(connectionRef);
      --
    begin
      --
      GetOrCreateNamedValue(valueName, namedValue_Ptr);

      -- klienta zaradim do zoznamu, ma ohodnotu zaujem
      if not Contains(namedValue_Ptr.clients, connectionRef) then
        Insert(namedValue_Ptr.clients, connectionRef, connectionInfo_Ptr);
      end if;
      -- poznacim si,ze mam o hodnotu zaujem (potrbujem pri odpojeni)
      if not Contains(connectionInfo_Ptr.values, valueName) then
        Insert(connectionInfo_Ptr.values, valueName, namedValue_Ptr);
      end if;

      -- zaslem mu aktualnu hodnotu
      declare
        msg_CPtr : CMessage_CPtr := new Client_Msgs.CChangeValue'
           (CMessage with
            valueName => valueName,
            value => namedValue_Ptr.currValue);

        bConnectionWasTerminated : Boolean;
      begin
        SendMessage(connectionRef, msg_CPtr, bConnectionWasTerminated);
      end;
      --
    end AttachValue;
    --
    procedure SetValue
       (connectionRef : in TConnectionRef;
        valueName     : in TValueName;
        value         : in TValue)
    is
      pragma Unreferenced (connectionRef);
      use ConnectionInfo_Pkg;
      --
      namedValue_Ptr : TNamedValue_Ptr;
      --
    begin
      --
      GetOrCreateNamedValue(valueName, namedValue_Ptr);
      --
      namedValue_Ptr.currValue := value;
      -- vsetkym klientom zaslem oznam o zmene hodnoty
      declare
        msg_CPtr : CMessage_CPtr;
        --
        c : Cursor := First(namedValue_Ptr.clients);
        --
        bConnectionWasTerminated : Boolean;
      begin
        loop
          exit when c = No_Element;
          --
          msg_CPtr := new Client_Msgs.CChangeValue'
             (CMessage with
              valueName => namedValue_Ptr.valueName,
              value => namedValue_Ptr.currValue);
          --
          SendMessage(Element(c).connectionRef, msg_CPtr, bConnectionWasTerminated);
          --
          c := Next(c);
        end loop;
      end;
      --
    end SetValue;
    --
    --
    procedure ConnectionWasDied
       (connectionRef : in TConnectionRef)
    is
      use ConnectionInfo_Pkg;
      --
      c : Cursor := Find(connectionsMap, connectionRef);
      --
    begin
      --
      if c = No_Element then
        -- neexistuje => FATAL ERROR
        Put_Line("ConnectionWasDied - Unknown connection.");
        raise Program_Error;
        --
      else
        -- odhlasim zo vsetkych hodnot
        declare
          use NamedValues_Pkg;
          --
          procedure Free is new Ada.Unchecked_Deallocation(TConnectionInfo, TConnectionInfo_Ptr);
          --
          connectionInfo_Ptr : TConnectionInfo_Ptr := Element(c);
          namedValue_Ptr : TNamedValue_Ptr;
          --
          currValue : NamedValues_Pkg.Cursor := First(connectionInfo_Ptr.values);
          --
        begin
          -- aj zo zoznamu klientov
          loop
            exit when currValue = NamedValues_Pkg.No_Element;
            --
            namedValue_Ptr := Element(currValue);
            Delete(namedValue_Ptr.clients, connectionRef);
            --
            currValue := Next(currValue);
          end loop;
          -- zrusim zoznam hodnot
          Clear(connectionInfo_Ptr.values);

          -- komunikaciu uz nebudem pouzivat
          Disconnect(connectionInfo_Ptr.connectionRef);
          Free(connectionInfo_Ptr);
          --
        end;
        --
        Delete(connectionsMap, c);
        --
      end if;
      --
    end ConnectionWasDied;
    --
    procedure ConnectionWasEstablised
       (connectionRef : in TConnectionRef)
    is
      use ConnectionInfo_Pkg;
      --
      c : Cursor := Find(connectionsMap, connectionRef);
      --
      connectionInfo_Ptr : TConnectionInfo_Ptr;
    begin
      --
      if c = No_Element then
        -- neexistuje => zalozim
        connectionInfo_Ptr := new TConnectionInfo'
           (connectionRef => connectionRef,
            values => NamedValues_Pkg.Empty_Map);
        -- a zaradim do zoznamu
        Insert(connectionsMap, connectionRef, connectionInfo_Ptr);
        --
      else -- existuje => FATAL ERROR
        Put_Line("ConnectionWasEstablised: Connection Allready exist " & GetConnectionName(connectionRef));
        raise Program_Error;
      end if;
      --
    end ConnectionWasEstablised;

  end Server;

  -----------------
  -- AttachValue --
  -----------------

  procedure AttachValue
     (connectionRef : in TConnectionRef;
      valueName     : in TValueName)
  is
  begin
    Server.AttachValue(connectionRef, valueName);
  end AttachValue;

  --------------
  -- SetValue --
  --------------

  procedure SetValue
     (connectionRef : in TConnectionRef;
      valueName     : in TValueName;
      value         : in TValue)
  is
  begin
    Server.SetValue(connectionRef, valueName, value);
  end SetValue;

  -----------------------
  -- ConnectionWasDied --
  -----------------------

  procedure ConnectionWasDied
     (connectionRef : in TConnectionRef)
  is
  begin
    Server.ConnectionWasDied(connectionRef);
  end ConnectionWasDied;

  -----------------------------
  -- ConnectionWasEstablised --
  -----------------------------

  procedure ConnectionWasEstablised
     (connectionRef : in TConnectionRef)
  is
  begin
    Server.ConnectionWasEstablised(connectionRef);
  end ConnectionWasEstablised;


end Server_Services;

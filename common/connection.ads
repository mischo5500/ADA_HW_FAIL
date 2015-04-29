with GNAT.Sockets;		use GNAT.Sockets;
package Connection is
  --
  type CMessage is abstract tagged private;
  type CMessage_CPtr is access all CMessage'Class;
  procedure Free (msg_CPtr : in out CMessage_CPtr);
  --
  procedure Action (Self : in CMessage);
  --
  --
  type TConnectionRef is private;
  function "<"(left, right : in TConnectionRef) return Boolean;
  notConnected : constant TConnectionRef;

  -- Inicializacia spojenia
  function InitConnection(socket : in Socket_Type;
                          connectionName : in String) return TConnectionRef;
  procedure Disconnect(c : in out TConnectionRef);

  -- Zaslanie spravy. Posielanu spravu si prevezme a msg_CPtr nastavi na null.
  -- Ak spojenie zlyhalo, bConnectionWasTerminated nastavi na True.
  procedure SendMessage(c : in TConnectionRef;
                        msg_CPtr : in out CMessage_CPtr;
                        bConnectionWasTerminated : out Boolean);
  --
  procedure GlobalInit;
  --
  function GetConnectionRef(msg : in CMessage'Class) return TConnectionRef;
  --
  function GetConnectionName(c : in TConnectionRef) return String;
  --
private
  --
  type TConnection;
  --
  type TConnectionRef is access TConnection;
  notConnected : constant TConnectionRef := null;
  --
  type CMessage is abstract tagged record
    connectionRef : TConnectionRef;
  end record;
  --
end Connection;

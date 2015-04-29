with Ada.Exceptions;
with Ada.Text_IO;		use Ada.Text_IO;
with GNAT.Sockets;		use GNAT.Sockets;

package body Client is

  -------------
  -- Connect --
  -------------

  function Connect
     (connectionName : in String;
      host : in String;
      portNr : in Natural)
      return TConnectionRef
  is
    c : TConnectionRef;
    Address  : Sock_Addr_Type;
    Socket   : Socket_Type;
  begin
    --
    Address.Addr := Loopback_Inet_Addr;--Addresses(Get_Host_By_Name(host), 1);
    Address.Port := Port_Type(portNr);
    Create_Socket (Socket);

    Set_Socket_Option
       (Socket,
        Socket_Level,
        (Reuse_Address, True));

    --  Force Pong to block

    --delay 0.2;

    --  If the client's socket is not bound, Connect_Socket will
    --  bind to an unused address. The client uses Connect_Socket to
    --  create a logical connection between the client's socket and
    --  a server's socket returned by Accept_Socket.
    begin
      Connect_Socket (Socket, Address);
      --
      c := InitConnection(Socket, connectionName);
      --
    exception when E: Socket_Error =>
        Put_Line(connectionName & ": Exception ocurred in Connect_Socket: " & Ada.Exceptions.Exception_Message(E));
    end;
    --
    return c;
    --
  end Connect;

end Client;

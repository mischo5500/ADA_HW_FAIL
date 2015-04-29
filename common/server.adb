with GNAT.Sockets;		use GNAT.Sockets;
with Ada.Text_IO;
with Connection;		use Connection;
with Ada.Exceptions;

--
with Connection_Msgs;
pragma Unreferenced(Connection_Msgs);
--
procedure Server is
  --
  procedure TCP_IP_Server is
    --
    Address  : Sock_Addr_Type;
    Server   : Socket_Type;
    Socket   : Socket_Type;
    nr : Integer;

  begin
    Connection.GlobalInit;

    --  Get an Internet address of a host (here the local host name).
    --  Note that a host can have several addresses. Here we get
    --  the first one which is supposed to be the official one.

    Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);

    --  Get a socket address that is an Internet address and a port

    Address.Port := 5876;

    --  The first step is to create a socket. Once created, this
    --  socket must be associated to with an address. Usually only a
    --  server (Pong here) needs to bind an address explicitly. Most
    --  of the time clients can skip this step because the socket
    --  routines will bind an arbitrary address to an unbound socket.

    Create_Socket (Server);

    --  Allow reuse of local addresses

    Set_Socket_Option
       (Server,
        Socket_Level,
        (Reuse_Address, True));

    Bind_Socket (Server, Address);

    --  A server marks a socket as willing to receive connect events

    Listen_Socket (Server);
    nr := 0;
    loop
      --  Once a server calls Listen_Socket, incoming connects events
      --  can be accepted. The returned Socket is a new socket that
      --  represents the server side of the connection. Server remains
      --  available to receive further connections.

      Accept_Socket (Server, Socket, Address);
      nr := nr + 1;
      declare
        c : Connection.TConnectionRef := Connection.InitConnection(Socket, nr'Img, True);
        pragma Unreferenced(c);
      begin
        null;
      end;
    end loop;

    Close_Socket (Server);
    --
  end TCP_IP_Server;
  --
begin
  TCP_IP_Server;
exception when E: others =>
    Ada.Text_IO.Put_Line(": Exception occured in Server: " & Ada.Exceptions.Exception_Message(E));
end Server;

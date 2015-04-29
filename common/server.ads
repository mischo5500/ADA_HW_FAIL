with GNAT.Sockets;		use GNAT.Sockets;

package Server is
  function WaitForClients(port_nr : in Port_Type) return Boolean;
end Server;

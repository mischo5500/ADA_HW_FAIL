with Server;
--with Ada.Command_Line;	use Ada.Command_Line;

procedure Server_Test is
  PORT_NR : constant := 12345;
  bOk : Boolean;
  pragma Unreferenced (bOk);
begin
  --
  bOk := Server.WaitForClients(PORT_NR);
end Server_Test;

with Ada.Text_IO;		use Ada.Text_IO;
with Server_Services;

package body Connection_Msgs is

  ------------
  -- Action --
  ------------

  procedure Action (Self : in CConnectionEstablised) is
  begin
    Server_Services.ConnectionWasEstablised(GetConnectionRef(Self));
    Put_Line("New client : " & GetConnectionName(GetConnectionRef(Self)));
  end Action;


  ------------
  -- Action --
  ------------

  procedure Action (Self : in CConnectionDied) is
    connName : String := GetConnectionName(GetConnectionRef(Self));
  begin
    Server_Services.ConnectionWasDied(GetConnectionRef(Self));
    Put_Line("Client done: " & connName);
  end Action;


end Connection_Msgs;

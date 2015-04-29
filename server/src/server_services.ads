with Connection; use Connection;
with ValueTypes; use ValueTypes;

package Server_Services is

  -- CLIENT -> SERVER
  -- klient connectionRef obdrzi oznam o kazdej zmene hodnoty "valueName"
  procedure AttachValue
     (connectionRef : in TConnectionRef;
      valueName     : in TValueName);


  -- CLIENT -> SERVER
  -- klient nastavi hodnotu value premennej "valueName"
  procedure SetValue
     (connectionRef : in TConnectionRef;
      valueName     : in TValueName;
      value         : in TValue);


  -- CONNECTION -> SERVER
  -- oznam o zaniku klienta
  procedure ConnectionWasDied
     (connectionRef : in TConnectionRef);

  -- CONNECTION -> SERVER
  -- oznam o zaniku klienta
  procedure ConnectionWasEstablised
     (connectionRef : in TConnectionRef);

end Server_Services;

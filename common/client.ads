with Connection;		use Connection;

package Client is

  function Connect(connectionName : in String;
                   host : in String;	-- parameter je ignorovany. Je pouzity Loopback_Inet_Addr
                   portNr : in Natural) return TConnectionRef;

end Client;

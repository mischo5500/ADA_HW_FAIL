with Connection;		use Connection;

package Connection_Msgs is

  ---------------------------
  -- CConnectionEstablised --
  ---------------------------
  -- Spravu generuje connection kniznica pri nadviazani spojenia Client/Server

  type CConnectionEstablised is new CMessage with null record;
  type CConnectionEstablised_CPtr is access all CConnectionEstablised'Class;
  --
  procedure Action(Self : in CConnectionEstablised);
  --

  ---------------------
  -- CConnectionDied --
  ---------------------
  -- Spravu generuje connection kniznica po
  -- ukonceni spojenia Client/Server

  type CConnectionDied is new CMessage with null record;
  type CConnectionDied_CPtr is access all CConnectionDied'Class;
  --
  procedure Action(Self : in CConnectionDied);
  --

end Connection_Msgs;

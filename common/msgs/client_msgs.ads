with Connection;	use Connection;
with ValueTypes;	use ValueTypes;

package Client_Msgs is
   Pritok : Long_Float := 0.0;
  ---------------------
  -- CConnectMessage --
  ---------------------
  -- Prva sprava ktoru klient posle
  -- Plni len informativny charakter
  type CConnectMessage is new CMessage with record
    clientName : TClientName;
  end record;
  type CConnectMessage_CPtr is access all CConnectMessage'Class;
  --
  procedure Action(Self : in CConnectMessage);
  --


  ------------------
  -- CAttachValue --
  ------------------
  -- CLIENT -> SERVER
  -- sprava, ktora volajucemu procesu zabezpeci zasielanie
  -- zmien hodnot veliciny valueName
  type CAttachValue is new CMessage with record
    valueName : TValueName;
  end record;
  procedure Action(Self : in CAttachValue);


  ------------------
  -- CChangeValue --
  ------------------
  -- SERVER -> CLIENT
  -- informacia o zmene hodnoty
  type CChangeValue is new CMessage with record --notifikacia od serva klientom
    valueName : TValueName; --identifikacia cez meno
    --
    value : TValue;
    --
  end record;
  type CAttachValue_CPtr is access all CAttachValue'Class;
  procedure Action(Self : in CChangeValue); --metoda action, ktora sa zavola ked pride klient


  ---------------
  -- CSetValue --
  ---------------
  -- CLIENT -> SERVER
  -- nastavenie novej hodnoty
  -- sprava sa pouziva na ovladanie hodnot
  type CSetValue is new CMessage with record
    valueName : TValueName;
    --
    value : TValue;
    --
  end record;
  type CSetValue_CPtr is access all CSetValue'Class;
  procedure Action(Self : in CSetValue);

end Client_Msgs;

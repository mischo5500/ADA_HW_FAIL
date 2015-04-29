pragma Ada_2005;

with Ada.Command_Line;
with Ada.Text_IO;	use Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Exceptions;
with Ada.Containers;		use Ada.Containers;
with Ada.Strings.Unbounded;	use Ada.Strings.Unbounded;

with Ada.Containers.Doubly_Linked_Lists;
with System;
with Connection_Msgs;

package body Connection is

  G_bDebug : Boolean := False;

  procedure Action (Self : in CMessage) is
  begin
    raise Program_Error;
  end Action;

  procedure Free (msg_CPtr : in out CMessage_CPtr) is
    procedure Free is new Ada.Unchecked_Deallocation (CMessage'Class, CMessage_CPtr);
  begin
    Free(msg_CPtr);
  end Free;

  procedure Put_Line(msg : in String) is
  begin
    if G_bDebug then
      Ada.Text_IO.Put_Line(msg);
    end if;
  end Put_Line;

  function "<"(left, right : in TConnectionRef) return Boolean is
    use System;
  begin
    return left.all'Address > right.all'Address;
  end "<";

  function GetConnectionRef(msg : in CMessage'Class) return TConnectionRef is
  begin
    return msg.connectionRef;
  end GetConnectionRef;


  package Message_List is new Ada.Containers.Doubly_Linked_Lists
     (Element_Type => CMessage_CPtr);



  -------------
  -- TSocket --
  -------------

  protected type TSocket is
    procedure SetSocket(s : in Socket_Type);
    function GetSocket return Socket_Type;
    procedure Close_Socket;
  private
    socket : Socket_Type := No_Socket;
  end TSocket;
  type TSocket_Ptr is access TSocket;

  -------------
  -- TSocket --
  -------------

  protected body TSocket is
    -- SetSocket --
    procedure SetSocket(s : in Socket_Type) is
    begin
      socket := s;
    end SetSocket;
    -- GetSocket --
    function GetSocket return Socket_Type is
    begin
      return socket;
    end GetSocket;
    -- Close_Socket --
    procedure Close_Socket is
    begin
      if socket /= No_Socket then
        begin
          Close_Socket(socket);
          exception when E: Socket_Error =>
            Ada.Text_IO.Put_Line("Exception occured in Close_Socket: " & Ada.Exceptions.Exception_Message(E));
        end;
        socket := No_Socket;
      end if;
    end Close_Socket;
    --
  end TSocket;


  ----------------
  -- TMsgsQueue --
  ----------------

  type TQueueType is (INQ, OUTQ);

  protected type TMsgsQueue is
    procedure WriteMessage(msg_CPtr : in out CMessage_CPtr; bQueueWasDestroyed : out Boolean);
    entry ReadMessage(msg_CPtr : out CMessage_CPtr; bQueueWasDestroyed : out Boolean);
    --
    procedure Init(qT : TQueueType; c : TConnectionRef);
    procedure DestroyQueue;
    --
  private
    msgsList : Message_List.List;
    bQueueWasDestroyed : Boolean := False;
    --
    qType : TQueueType;
    connectionRef : TConnectionRef;
    --
  end TMsgsQueue;
  type TMsgsQueue_Ptr is access TMsgsQueue;

  ----------------------
  -- TReader_Tsk spec --
  ----------------------

  task type TReader_Tsk is
    entry Init(cr : in TConnectionRef);
  end TReader_Tsk;
  type TReader_Tsk_Ptr is access TReader_Tsk;

  ----------------------
  -- TWriter_Tsk spec --
  ----------------------

  task type TWriter_Tsk is
    entry Init(cr : in TConnectionRef);
  end TWriter_Tsk;
  type TWriter_Tsk_Ptr is access TWriter_Tsk;
  ------------------------
  -- TExecutor_Tsk spec --
  ------------------------

  task type TExecutor_Tsk is
    entry Init(cr : in TConnectionRef);
  end TExecutor_Tsk;
  type TExecutor_Tsk_Ptr is access TExecutor_Tsk;

  -----------------
  -- TConnection --
  -----------------

  type TConnection is record
    connectionName : UnBounded_String;
    --
    socket : TSocket_Ptr;
    --
    inQ : TMsgsQueue_Ptr;
    outQ : TMsgsQueue_Ptr;
    -- vstupna a vystupna fronta komunikacie
    reader_tsk : TReader_Tsk_Ptr;
    writer_tsk : TWriter_Tsk_Ptr;
    --
    executor_tsk : TExecutor_Tsk_Ptr;
    --
    bDisconnectPerformed : Boolean := False;
  end record;

  -----------------------
  -- GetConnectionName --
  -----------------------

  function GetConnectionName(c : in TConnectionRef) return String is
  begin
    return To_String(c.connectionName);
  end GetConnectionName;

  ----------------
  -- TGraveyard --
  ----------------

  package Connection_List is new Ada.Containers.Doubly_Linked_Lists
     (Element_Type => TConnectionRef);


  protected type TGraveyard is
    procedure ConnectionTerminated(c : in TConnectionRef);
    entry FreeTerminatedConnections;
  private
    connections : Connection_List.List;
    nrConnections : Integer := 0;
  end TGraveyard;

  procedure Free(c : in out TConnectionRef) is
    procedure Free is new Ada.Unchecked_Deallocation(TConnection, TConnectionRef);
    procedure Free is new Ada.Unchecked_Deallocation(TReader_Tsk, TReader_Tsk_Ptr);
    procedure Free is new Ada.Unchecked_Deallocation(TWriter_Tsk, TWriter_Tsk_Ptr);
    procedure Free is new Ada.Unchecked_Deallocation(TExecutor_Tsk, TExecutor_Tsk_Ptr);
    procedure Free is new Ada.Unchecked_Deallocation(TSocket, TSocket_Ptr);
    procedure Free is new Ada.Unchecked_Deallocation(TMsgsQueue, TMsgsQueue_Ptr);
  begin
    --
    Free(c.reader_tsk);
    Free(c.writer_tsk);
    Free(c.executor_tsk);
    --
    Free(c.inQ);
    Free(c.outQ);
    --
    Free(c.socket);
    --
    Free(c);
  end Free;



  protected body TGraveyard is
    -- ConnectionTerminated --
    procedure ConnectionTerminated(c : in TConnectionRef) is
      use Connection_List;
    begin
      Append(connections, c);
      nrConnections := nrConnections + 1;
    end ConnectionTerminated;

    -- FreeTerminatedConnections --
    entry FreeTerminatedConnections when nrConnections > 0 is
      use Connection_List;
      c : Cursor := First(connections);	-- od zaciatku
      connectionRef : TConnectionRef;
    begin
      --
      loop
        --
        exit when c = Connection_List.No_Element;
        --
        connectionRef := Element(c);	-- connection
        -- ak je uplne ukoncena
        if connectionRef.bDisconnectPerformed and then
           connectionRef.reader_tsk'Terminated and then
           connectionRef.writer_tsk'Terminated and then
           connectionRef.executor_tsk'Terminated then
          -- dalsi bude
          declare
            next : Connection_List.Cursor := Connection_List.Next(c);
          begin
            Put_Line(To_String(connectionRef.connectionName) & ": Was died.");
            -- dealokujem aktualny
            Free(connectionRef);
            -- a vyradim ho zo zoznamu
            Delete(connections, c);
            nrConnections := nrConnections - 1;
            -- a pokracujem
            c := next;
          end;
        else -- dalsi
          Put_Line(To_String(connectionRef.connectionName) & ": Waiting to die.");
          c := Next(c);
        end if;
        --
      end loop;
    end FreeTerminatedConnections;
    --
  end TGraveyard;
  type TGraveyard_Ptr is access TGraveyard;
  GRAVEYARD_PTR : TGraveyard_Ptr;

  --------------------
  -- TGraveyard_Tsk --
  --------------------

  task type TGraveyard_Tsk is
    entry Start;
  end TGraveyard_Tsk;

  --------------------
  -- TGraveyard_Tsk --
  --------------------

  task body TGraveyard_Tsk is
  begin
    accept Start;
    --
    loop
      GRAVEYARD_PTR.FreeTerminatedConnections;
      delay 1.0;
    end loop;
    --
  exception when E: others =>
      Ada.Text_IO.Put_Line(": Exception occured in TGraveyard_Tsk: " & Ada.Exceptions.Exception_Message(E));
  end TGraveyard_Tsk;

  ----------------
  -- TMsgsQueue --
  ----------------

  protected body TMsgsQueue is
    -- WriteMessage --
    procedure WriteMessage(msg_CPtr : in out CMessage_CPtr; bQueueWasDestroyed : out Boolean) is
      use Message_List;
    begin
      --
      bQueueWasDestroyed := TMsgsQueue.bQueueWasDestroyed;
      --
      if not bQueueWasDestroyed then
        -- vlozim spravu
        Append(msgsList, msg_CPtr);
        msg_CPtr := null;
      end if;
    end WriteMessage;

    -- ReadMessage --
    entry ReadMessage(msg_CPtr : out CMessage_CPtr; bQueueWasDestroyed : out Boolean) when
       Message_List.Length(msgsList) > 0 or
       bQueueWasDestroyed
    is
      use Message_List;
    begin
      --
      bQueueWasDestroyed := TMsgsQueue.bQueueWasDestroyed;
      --
      if bQueueWasDestroyed then
        msg_CPtr := null;
      else
        msg_CPtr := First_Element(msgsList);
        Delete_First(msgsList);
      end if;
    end ReadMessage;

    -- DestroyQueue --
    procedure DestroyQueue is
      use Message_List;
    begin
      if not bQueueWasDestroyed then
        bQueueWasDestroyed := True;
        -- dealokujem obsah fronty
        declare
          procedure FreeElm(Position : Cursor) is
            msg_CPtr : CMessage_CPtr := Element(Position);
          begin
            Free(msg_CPtr);
          end FreeElm;
        begin
          Iterate(msgsList, FreeElm'Access);
        end;
        --
        Clear(msgsList);
        --
        Put_Line(To_String(connectionRef.connectionName) & ": " & qType'Img & " was destroyed.");
        --
      end if;
    end DestroyQueue;

    procedure Init(qT : TQueueType; c : TConnectionRef) is
    begin
      qType := qT;
      connectionRef := c;
    end Init;

  end TMsgsQueue;

  ----------------------
  -- TReader_Tsk body --
  ----------------------

  task body TReader_Tsk is
    connectionRef : TConnectionRef;
    channel : Stream_Access;
    bQueueWasDestroyed : Boolean;
  begin
    accept Init(cr : in TConnectionRef) do
      connectionRef := cr;
    end;
    --
    channel := Stream(connectionRef.socket.GetSocket);
    --
    Put_Line(To_String(connectionRef.connectionName) & ": TReader_Tsk -> READY");
    begin
      loop
        declare
          msg_CPtr : CMessage_CPtr := new CMessage'Class'(CMessage'Class'Input(channel));
        begin
          --
          connectionRef.inQ.WriteMessage(msg_CPtr, bQueueWasDestroyed);
          --
          if bQueueWasDestroyed then
            -- spravu ktoru som prijal odalokujem
            Free(msg_CPtr);
            --
            Put_Line(To_String(connectionRef.connectionName) & ": TReader_Tsk: inQ was destroyed.");
            exit;
          end if;
          --
        end;
      end loop;
    exception when E: Socket_Error| End_Error =>
        Put_Line(To_String(connectionRef.connectionName) & ": Exception occured in TReader_Tsk: " & Ada.Exceptions.Exception_Message(E));
        -- Tato cinnost sa vyskytne v pripade komunikacnej chyby
        -- inQ oznacim ako zrusenu. Tym oznamim TExecutor_Tsk, ze je koniec
        connectionRef.inQ.DestroyQueue;
        -- outQ oznacim ako zrusenu. Tym oznamim TWriter_Tsk, ze je koniec
        connectionRef.outQ.DestroyQueue;
        --
    end;
    -- Clean up
    Free(channel);
    --
    Put_Line(To_String(connectionRef.connectionName) & ": TReader_Tsk -> END");
    --
  exception when E: others =>
      Ada.Text_IO.Put_Line(": Exception occured in TReader_Tsk: " & Ada.Exceptions.Exception_Message(E));
  end TReader_Tsk;

  ----------------------
  -- TWriter_Tsk body --
  ----------------------

  task body TWriter_Tsk is
    connectionRef : TConnectionRef;
    channel : Stream_Access;
  begin
    accept Init(cr : in TConnectionRef) do
      connectionRef := cr;
    end;
    --
    channel := Stream(connectionRef.socket.GetSocket);
    --
    Put_Line(To_String(connectionRef.connectionName) & ": TWriter_Tsk -> READY");
    --
    declare
      msg_CPtr : CMessage_CPtr;
      bQueueWasDestroyed : Boolean;
    begin
      loop
        --
        connectionRef.outQ.ReadMessage(msg_CPtr, bQueueWasDestroyed);
        --
        exit when bQueueWasDestroyed;
        --
        CMessage'Class'Output(channel, msg_CPtr.all);
        --
        Free(msg_CPtr);
        --
      end loop;
    exception when E: Socket_Error| End_Error =>
        Ada.Text_IO.Put_Line(To_String(connectionRef.connectionName) & ": Exception occured in TWriter_Tsk: " & Ada.Exceptions.Exception_Message(E));
        Free(msg_CPtr);
        -- Tato cinnost sa vyskytne v pripade komunikacnej chyby
        -- outQ oznacim ako zrusenu.
        connectionRef.outQ.DestroyQueue;
        -- inQ oznacim ako zrusenu. Tym oznamim taskom TExecutor_Tsk a TReader_Tsk, ze je koniec
        connectionRef.inQ.DestroyQueue;
        --
    end;
    -- Clean up
    Free(channel);
    --
    Put_Line(To_String(connectionRef.connectionName) & ": TWriter_Tsk -> END");
    --
  exception when E: others =>
      Ada.Text_IO.Put_Line(": Exception occured in TWriter_Tsk: " & Ada.Exceptions.Exception_Message(E));
  end TWriter_Tsk;


  ------------------------
  -- TExecutor_Tsk body --
  ------------------------

  task body TExecutor_Tsk is
    connectionRef : TConnectionRef;
    msg_CPtr : CMessage_CPtr;
    bQueueWasDestroyed : Boolean;
  begin
    accept Init(cr : in TConnectionRef) do
      connectionRef := cr;
    end;
    --
    declare
      use Connection_Msgs;
      msg : CConnectionEstablised;
    begin
      CMessage(msg).connectionRef := connectionRef;
      Action(msg);
    end;
    --
    loop
      --
      connectionRef.inQ.ReadMessage(msg_CPtr, bQueueWasDestroyed);
      --
      exit when bQueueWasDestroyed;
      -- identifikacia kontextu
      msg_CPtr.connectionRef := connectionRef;
      Action(msg_CPtr.all);
      --
      Free(msg_CPtr);
      --
    end loop;
    --
    -- inQ aj outQ su v stave Destroyed => tasky TReader_Tsk aj TWriter_Tsk skoncia
    connectionRef.socket.Close_Socket;
    --
    declare
      use Connection_Msgs;
      msg : CConnectionDied;
    begin
      CMessage(msg).connectionRef := connectionRef;
      Action(msg);
    end;

    --
    Put_Line(To_String(connectionRef.connectionName) & ": TExecutor_Tsk -> END");
    -- pridam do zoznamu ukoncenych spojeni
    GRAVEYARD_PTR.ConnectionTerminated(connectionRef);
    --
  exception when E: others =>
      Ada.Text_IO.Put_Line(": Exception occured in TExecutor_Tsk: " & Ada.Exceptions.Exception_Message(E));
  end TExecutor_Tsk;

  --------------------
  -- InitConnection --
  --------------------

  function InitConnection
     (socket : in Socket_Type;
      connectionName : in String)
      return TConnectionRef
  is
    cr : TConnectionRef;
  begin
    --
    Put_Line(connectionName & ": InitConnection");
    cr := new TConnection;
    --
    cr.connectionName := To_UnBounded_String(connectionName);
    cr.bDisconnectPerformed := False;	-- nebol volany Disconnect zo strany uzivatela
    --
    cr.socket := new TSocket;
    cr.socket.SetSocket(socket);
    --
    cr.inQ := new TMsgsQueue;
    cr.inQ.Init(INQ, cr);
    --
    cr.outQ := new TMsgsQueue;
    cr.outQ.Init(OUTQ, cr);
    --
    cr.reader_tsk := new TReader_Tsk;
    cr.reader_tsk.Init(cr);
    --
    cr.writer_tsk := new TWriter_Tsk;
    cr.writer_tsk.Init(cr);
    --
    cr.executor_tsk := new TExecutor_Tsk;
    cr.executor_tsk.Init(cr);
    --
    return cr;
  end InitConnection;

  ----------------
  -- Disconnect --
  ----------------

  procedure Disconnect
     (c : in out TConnectionRef)
  is
  begin
    --
    c.outQ.DestroyQueue;
    c.inQ.DestroyQueue;
    --
    c.socket.Close_Socket;
    --
    Put_Line(To_String(c.connectionName) & ": Disconnect");
    --
    c.bDisconnectPerformed := True;
    --
    c := null;
  end Disconnect;

  -----------------
  -- SendMessage --
  -----------------

  procedure SendMessage
     (c : in TConnectionRef;
      msg_CPtr : in out CMessage_CPtr;
      bConnectionWasTerminated : out Boolean)
  is
    bQueueWasDestroyed : Boolean;
  begin
    -- zapis do vystupnej fronty
    c.outQ.WriteMessage(msg_CPtr, bQueueWasDestroyed);
    bConnectionWasTerminated := bQueueWasDestroyed;
    -- spravu ktoru som neodoslal dealokujem
    if bQueueWasDestroyed then
      --
      Put_Line(To_String(c.connectionName) & ": SendMessage to destroyed connection");
      Free(msg_CPtr);
      --
    end if;
    --
  end SendMessage;

  ----------------
  -- GlobalInit --
  ----------------

  type TGraveyard_Tsk_Ptr is access TGraveyard_Tsk;
  tmp_Ptr : TGraveyard_Tsk_Ptr;

  procedure GlobalInit is
  begin
    --
    for i in 1 .. Ada.Command_Line.Argument_Count loop
      if Ada.Command_Line.Argument(i) = "/CD" then
        G_bDebug := True;
      end if;
    end loop;
    --
    GRAVEYARD_PTR := new TGraveyard;
    tmp_Ptr := new TGraveyard_Tsk;
    tmp_Ptr.Start;
  end GlobalInit;

end Connection;

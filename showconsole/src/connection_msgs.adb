
with Ada.Text_IO;	use Ada.Text_IO;
with GNAT.OS_Lib;
package body Connection_Msgs is

  ------------
  -- Action --
  ------------

  procedure Action(Self : in CConnectionEstablised) is
  begin
    Put_Line("CConnectionEstablised");
  end Action;

  ------------
  -- Action --
  ------------

  procedure Action(Self : in CConnectionDied) is
  begin
    Put_Line("CConnectionDied => Exit process");
    --
    GNAT.OS_Lib.OS_Exit(0);
    --
  end Action;

end Connection_Msgs;

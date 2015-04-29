with Ada.Unchecked_Deallocation;

package MessageBase is
  --
  type CMessage is abstract tagged private;
  type CMessage_CPtr is access all CMessage'Class;
  procedure Free is new Ada.Unchecked_Deallocation(CMessage'Class, CMessage_CPtr);
  --
  procedure Action (Self : in CMessage) is abstract;
  --
end MessageBase;

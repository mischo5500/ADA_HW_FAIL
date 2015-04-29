-----------------------------------------
-- Sorting package
-----------------------------------------
package My_Archive is
   type Float_Vector is array (Positive range <>) of Float;
   -- procedure for bubble sort
   function Archive_it(A: in out Float_Vector) return Float_Vector;
end My_Archive;

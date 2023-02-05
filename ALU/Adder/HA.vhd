-----------------------------------------------------------
--
-- Half Adder
--
-- 1-bit half adder component
--
-- B. Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HA is 
port (
		x1, x2        : in STD_LOGIC;
		y, cout : out STD_LOGIC
	);
end HA;

architecture structure of HA is

begin       -- note that all of the following statements are concurrent
       

    y <=  x1 xor x2; -- sum
    cout <=  x1 and x2; -- carry
    
 end structure;
-----------------------------------------------------------
--
-- Full Adder
--
-- 1-bit full adder component
--
-- B. Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FA is 
port (
		x1, x2, cin        : in STD_LOGIC;
		y, cout : out STD_LOGIC
	);
end FA;

architecture structure of FA is

	signal s1, c1, c2 : STD_LOGIC;  -- internal signals
        
	component 1_bit_half_adder is
		port(x1, x2 : in std_logic;
			y, cout : out std_logic);
	end component;
	
	begin 
	
	cout <= c1 or c2
	
	u1: 1_bit_half_adder port map (x1=>x1, x2=>x2, y=>s1, cout=>c1);
	u2: 1_bit_half_adder port map (x1=>cin, x2=>s1, y=>y, cout=>c2);
	
end structure;
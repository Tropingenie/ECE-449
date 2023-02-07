-----------------------------------------------------------
--
-- 4-bit Ripple Adder
--
-- 4-bit ripple carry adder
--
-- B. Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adder is
port(
	a, b	: in std_logic_vector(3 downto 0);
    cin		: in std_logic;
    y		: out std_logic_vector(3 downto 0);
    cout	: out std_logic);
end adder;

architecture structure of adder is

	signal c: std_logic_vector(2 downto 0);
    
    component FA is
    	port(x1, x2, cin: in std_logic;
        	y, cout: out std_logic);
    end component;
    
begin

	fa0: FA port map (x1=>a(0), x2=>b(0), cin=>cin,  y=>y(0), cout=>c(0));
    fa1: FA port map (x1=>a(1), x2=>b(1), cin=>c(0), y=>y(1), cout=>c(1));
    fa2: FA port map (x1=>a(2), x2=>b(2), cin=>c(1), y=>y(2), cout=>c(2));
    fa3: FA port map (x1=>a(3), x2=>b(3), cin=>c(2), y=>y(3), cout=>cout);

end structure;
-----------------------------------------------------------
--
-- Barrel Shifter
--
-- Barrel shifter implemented using built in VHDL slice
-- and concatenation operations.
--
-- Ben Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BarrelShifter is
port(direction : in std_logic; -- Right shift is "positive" == one
	 shift_amount : in std_logic_vector(3 downto 0);
	 rin : in std_logic_vector(15 downto 0);
	 rout : out std_logic_vector(15 downto 0));
end BarrelShifter;

architecture structure of BarrelShifter is

signal s3, s2, s1, s0 : std_logic_vector(1 downto 0); -- selects of each DMUX bank
signal tmp4, tmp3, tmp2, tmp1 : std_logic_vector(15 downto 0);

begin

-- concatenate shift enable with direction
-- for signal input
s3 <= shift_amount(3) & direction;
s2 <= shift_amount(2) & direction;
s1 <= shift_amount(1) & direction;
s0 <= shift_amount(0) & direction;

-- Level 4 (8 bit shift)
tmp4 <= rin 						when s3 = "00" else -- No shift
		rin 						when s3 = "01" else -- No shift
	 	x"00" & rin(15 downto 8) 	when s3 = "10" else -- Right shift
	 	rin(7 downto 0) & x"00" 	when s3 = "11";		-- Left shift

-- Level 2 (4 bit shift)
tmp3 <= tmp4 						when s2 = "00" else -- No shift
		tmp4 						when s2 = "01" else -- No shift
	 	x"0" & tmp4(15 downto 4) 	when s2 = "10" else -- Right shift
	 	tmp4(11 downto 0) & x"0" 	when s2 = "11";		-- Left shift

-- Level 2 (2 bit shift)
tmp2 <= tmp3 						when s1 = "00" else -- No shift
		tmp3 						when s1 = "01" else -- No shift
	 	"00" & tmp3(15 downto 2) 	when s1 = "10" else -- Right shift
	 	tmp3(13 downto 0) & "00" 	when s1 = "11";		-- Left shift

-- Level 1 (1 bit shift)
tmp1 <= tmp2 						when s0 = "00" else -- No shift
		tmp2 						when s0 = "01" else -- No shift
	 	'0' & tmp2(15 downto 1) 	when s0 = "10" else -- Right shift
	 	tmp2(14 downto 0) & '0' 	when s0 = "11";		-- Left shift

-- Output
rout <= tmp1;


end structure;
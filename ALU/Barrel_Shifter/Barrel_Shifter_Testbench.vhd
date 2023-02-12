-- Testbench for FA
library IEEE;
use IEEE.std_logic_1164.all;
 
entity testbench is
-- empty
end testbench; 

architecture tb of testbench is

-- DUT component
component barrelshifter is
port(
	 direction : in std_logic; -- Right shift is "positive" == one
	 shift_amount : in std_logic_vector(3 downto 0);
	 rin : in std_logic_vector(15 downto 0);
	 rout : out std_logic_vector(15 downto 0));
end component;

signal direction : std_logic; -- Right shift is "positive" == one
signal	 shift_amount : std_logic_vector(3 downto 0);
signal	 rin :  std_logic_vector(15 downto 0);
signal	 rout :  std_logic_vector(15 downto 0);

begin

  -- Connect DUT
  DUT: barrelshifter port map(direction, shift_amount, rin, rout);
  
  process
  begin

	assert false report "Right shifts." severity note;
    direction <= '0';    
    rin <= x"FFFF";
    shift_amount <= x"8";
    wait for 100 ns;
    assert rout = x"00FF" report "T1 Mismatch: " & to_hstring(rout) severity failure;
       
    rin <= x"FFFF";
    shift_amount <= x"F";
    wait for 100 ns;
    assert rout = x"0001" report "T2 Mismatch: " & to_hstring(rout) severity failure;
     
    rin <= x"FFFF";
    shift_amount <= x"1";
    wait for 100 ns;
    assert rout = "0111" & x"FFF" report "T3 Mismatch: " & to_hstring(rout) severity failure;
    
    	assert false report "Left shifts." severity note;
    direction <= '1';    
    rin <= x"FFFF";
    shift_amount <= x"8";
    wait for 100 ns;
    assert rout = x"FF00" report "T1 Mismatch: " & to_hstring(rout) severity failure;
       
    rin <= x"FFFF";
    shift_amount <= x"F";
    wait for 100 ns;
    assert rout = "1000"&x"000" report "T2 Mismatch: " & to_hstring(rout) severity failure;
     
    rin <= x"FFFF";
    shift_amount <= x"1";
    wait for 100 ns;
    assert rout = x"FFF" & "1110" report "T3 Mismatch: " & to_hstring(rout) severity failure;
  
  
  
    assert false report "Tests done." severity note;
    wait;
  end process;
end tb;

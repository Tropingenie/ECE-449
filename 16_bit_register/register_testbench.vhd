-- Testbench for FA
library IEEE;
use IEEE.std_logic_1164.all;
 
entity testbench is
-- empty
end testbench; 

architecture tb of testbench is

-- DUT component
component theRegister is
port(
    clk : in std_logic;
    d_in : in std_logic_vector(15 downto 0);
    d_out : out std_logic_vector(15 downto 0));
end component;

signal input, output : std_logic_vector(15 downto 0);
signal clk: std_logic;

begin

  -- Connect DUT
  DUT: theRegister port map(clk=>clk, d_in=>input, d_out=>output);
  
  process
  begin

	assert false report "Begin" severity note;

	clk <= '0';
    input <= x"FFFF";
    wait for 20 ns;
    clk <= '1';
    wait for 20 ns;
    clk <= '0';
    assert output = x"FFFF" report "T1 Mismatch: " & to_hstring(output) severity failure;
       
    assert false report "Tests done." severity note;
    wait;

  end process;
end tb;

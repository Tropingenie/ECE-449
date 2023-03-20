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
    clk, rst : in std_logic;
    d_in : in std_logic_vector(15 downto 0);
    d_out : out std_logic_vector(15 downto 0));
end component;

signal input, output : std_logic_vector(15 downto 0);
signal clk, clkr, clken, rst: std_logic;

begin

  -- Connect DUT
  DUT: theRegister port map(clk=>clkr, rst=>rst, d_in=>input, d_out=>output);
  
  process begin
      wait for 20 ns;
        clk <= '1';
     wait for 20 ns;
        clk <= '0';
  end process;
  
  clkr <= clk and clken;
  
  process
  begin
    rst <= '1';
    wait until (clk='1' and clk'event);
    rst <= '0';
    clken <= '1';

--	assert false report "Begin" severity note;
    input <= x"FFFF";
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
--    assert output = x"FFFF" report "T1 Mismatch: " & to_hstring(output) severity failure;
    

    input <= x"1234";
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);

    clken <= '0';
    input <= x"AAAA";
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
--    assert output = x"1234" report "T1 Mismatch: " & to_hstring(output) severity failure;
       
--    assert false report "Tests done." severity note;
    wait;

  end process;
end tb;

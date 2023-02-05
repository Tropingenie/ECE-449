-----------------------------------------------------------
--
-- Full Adder Testbench
--
-- Tests 1-bit full adder component
--
-- B. Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
 
entity testbench is
-- empty
end testbench; 

architecture tb of testbench is

-- DUT component
component or_gate is
port(
  a: in std_logic;
  b: in std_logic;
  q: out std_logic);
end component;

component FA is
port( x1, x2, cin: in std_logic;
	y, cout: out std_logic
    );
end component;

signal a_in, b_in, c_in, q_out, c_out: std_logic;

begin

  -- Connect DUT
  DUT: FA port map(a_in, b_in, c_in, q_out, c_out);

  process
  begin
    assert false report "Begin no carry tests" severity note;
  	c_in <= '0';
  
    a_in <= '0';
    b_in <= '0';
    wait for 4 ns;
    assert(q_out='0') report "Wrong sum 0 + 0" severity error;
    assert(c_out='0') report "Wrong carry 0 + 0" severity error;
  
    a_in <= '0';
    b_in <= '1';
    wait for 4 ns;
    assert(q_out='1') report "Fail 0 + 1" severity error;
    assert(c_out='0') report "Wrong carry 0 + 1" severity error;

    a_in <= '1';
    b_in <= '0';
    wait for 4 ns;
    assert(q_out='1') report "Fail 1 + 0" severity error;
    assert(c_out='0') report "Wrong carry 1 + 0" severity error;

    a_in <= '1';
    b_in <= '1';
    wait for 4 ns;
    assert(q_out='0') report "Fail 1 + 1" severity error;
    assert(c_out='1') report "Wrong carry 1 + 1" severity error;
    
    --------------------------------------------------------
    
    assert false report "Begin with carry tests" severity note;
  	c_in <= '1';
  
    a_in <= '0';
    b_in <= '0';
    wait for 4 ns;
    assert(q_out='1') report "Wrong sum 0 + 0" severity error;
    assert(c_out='0') report "Wrong carry 0 + 0" severity error;
  
    a_in <= '0';
    b_in <= '1';
    wait for 4 ns;
    assert(q_out='0') report "Fail 0 + 1" severity error;
    assert(c_out='1') report "Wrong carry 0 + 1" severity error;

    a_in <= '1';
    b_in <= '0';
    wait for 4 ns;
    assert(q_out='0') report "Fail 1 + 0" severity error;
    assert(c_out='1') report "Wrong carry 1 + 0" severity error;

    a_in <= '1';
    b_in <= '1';
    wait for 4 ns;
    assert(q_out='1') report "Fail 1 + 1" severity error;
    assert(c_out='1') report "Wrong carry 1 + 1" severity error;
    
    -- Clear inputs
    a_in <= '0';
    b_in <= '0';
    c_in <= '0';

    assert false report "Tests done." severity note;
    wait;
  end process;
end tb;

-----------------------------------------------------------
--
-- Std Register
--
-- "Standard" register for this project (16 bits)
--
-- Ben Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity theRegister is
port(
    clk, rst : in std_logic;
    d_in : in std_logic_vector(15 downto 0);
    d_out : out std_logic_vector(15 downto 0));
end theRegister;

architecture Behaviour of theRegister is

component FlipFlop is
port(
    D, clk : in std_logic;
    Q : out std_logic);
end component;

begin

process(clk) begin
    if rst = '1' then
        d_out <= (others=>'0');
    elsif rising_edge(clk) then
    d_out <= d_in;
    end if;
    end process;

end Behaviour;
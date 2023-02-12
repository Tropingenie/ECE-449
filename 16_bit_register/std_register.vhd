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
    clk : in std_logic;
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

    b0: FlipFlop port map(D=>d_in(0), clk=>clk, Q=>d_out(0));
    b1: FlipFlop port map(D=>d_in(1), clk=>clk, Q=>d_out(1));
    b2: FlipFlop port map(D=>d_in(2), clk=>clk, Q=>d_out(2));
    b3: FlipFlop port map(D=>d_in(3), clk=>clk, Q=>d_out(3));
    b4: FlipFlop port map(D=>d_in(4), clk=>clk, Q=>d_out(4));
    b5: FlipFlop port map(D=>d_in(5), clk=>clk, Q=>d_out(5));
    b6: FlipFlop port map(D=>d_in(6), clk=>clk, Q=>d_out(6));
    b7: FlipFlop port map(D=>d_in(7), clk=>clk, Q=>d_out(7));
    b8: FlipFlop port map(D=>d_in(8), clk=>clk, Q=>d_out(8));
    b9: FlipFlop port map(D=>d_in(9), clk=>clk, Q=>d_out(9));
    b10: FlipFlop port map(D=>d_in(10), clk=>clk, Q=>d_out(10));
    b11: FlipFlop port map(D=>d_in(11), clk=>clk, Q=>d_out(11));
    b12: FlipFlop port map(D=>d_in(12), clk=>clk, Q=>d_out(12));
    b13: FlipFlop port map(D=>d_in(13), clk=>clk, Q=>d_out(13));
    b14: FlipFlop port map(D=>d_in(14), clk=>clk, Q=>d_out(14));
    b15: FlipFlop port map(D=>d_in(15), clk=>clk, Q=>d_out(15));

end Behaviour;
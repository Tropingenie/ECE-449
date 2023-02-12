-----------------------------------------------------------
--
-- D Flip Flop
--
-- Generic D Flip Flop
--
-- Ben Lyne
--
-----------------------------------------------------------

entity FlipFlop is
port(
    D, clk : in std_logic;
    Q : out std_logic);
end FlipFlop;

component DLatch is
port(
    D, E : in std_logic;
    Q : out std_logic
);
end DLatch;

architecture Behavioral of FlipFlop is:

signal master_out, not_clk : std_logic;

begin
not_clk = not clk;
master: DLatch port map(D=>D, clk=>not_clk, Q=>master_out);
slave: DLatch port map(D=>master_out, clk=>clk, Q=>Q);

end Behavioral;
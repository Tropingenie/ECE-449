-----------------------------------------------------------
--
-- Instruction Fetcher
--
-- Plug in module to fetch instructions from instruction
-- memory. PC is contained within this module. Handles
-- incrementing PC, issuing PC to the instruction memory,
-- handshaking with instruction memory, and strobing data
-- from instruction memory.
--
-- Benjamin Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity InstructionFetcher is
port(
    M_INSTR : in std_logic_vector(15 downto 0); -- Input from memory
    clk, double_clk : in std_logic; -- clock at twice the rate of the datapath, PC gets double clk to strobe properly
    INSTR, M_ADDR : out std_logic_vector(15 downto 0); -- Instruction output and memory address issuing respectively
);
end InstructionFetcher;

architecture Behaviour of InstructionFetcher is

component theregister is
port(
    clk : in std_logic;
    d_in : in std_logic_vector(15 downto 0);
    d_out : out std_logic_vector(15 downto 0));
end component;

begin

    signal current_pc, next_pc : std_logic_vector(15 downto 0);

    PC: theregister port map (clk=>double_clk, d_in => next_pc, d_out => current_pc);

    INST <= M_INSTR; -- Just pass through. This module is only a controller

    process(clk, rst)
    begin
        if rst = '1' or next_pc = x"UUUU" then
            current_pc <= (others=>'0');
            next_pc <= (others=>'0');
        elsif RISING_EDGE(clk) then
            next_pc <= current_pc + 2;
            M_ADDR <= current_pc;
        end if;
    end process;

end Behaviour
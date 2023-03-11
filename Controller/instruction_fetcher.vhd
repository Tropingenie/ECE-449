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
use IEEE.NUMERIC_STD.ALL;

entity InstructionFetcher is
port(
    M_INSTR : in std_logic_vector(15 downto 0); -- Input from memory
    clk, rst : in std_logic;
    INSTR, M_ADDR : out std_logic_vector(15 downto 0) -- Instruction output and memory address issuing respectively
);
end InstructionFetcher;

architecture Behaviour of InstructionFetcher is

component theregister is
port(
    clk, rst : in std_logic;
    d_in : in std_logic_vector(15 downto 0);
    d_out : out std_logic_vector(15 downto 0));
end component;

signal current_pc, next_pc : std_logic_vector(15 downto 0);

begin

    PC : theregister port map (clk=>clk, rst=>rst, d_in => next_pc, d_out => current_pc);

    INSTR <= M_INSTR; -- Just pass through. This module is only a controller

    process(clk, rst)
    begin
        if rst = '1' or next_pc = "UUUU" then
            M_ADDR <= (others=>'0');
        elsif RISING_EDGE(clk) then
            next_pc <= std_logic_vector(unsigned(current_pc) + x"0002");
            M_ADDR <= current_pc;
        end if;
    end process;

end Behaviour;
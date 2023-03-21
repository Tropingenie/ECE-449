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
    clk, rst, bubble : in std_logic;
    PC : out std_logic_vector(15 downto 0) -- Instruction output and memory address issuing respectively
);
end InstructionFetcher;

architecture Behaviour of InstructionFetcher is

component theregister is
port(
    clk, rst : in std_logic;
    d_in : in std_logic_vector(15 downto 0);
    d_out : out std_logic_vector(15 downto 0));
end component;

signal current_pc, next_pc : std_logic_vector(15 downto 0) := (others => '0');

begin

    REG_PC : theregister port map (clk=>clk, rst=>rst, d_in => next_pc, d_out => current_pc);
    process(clk, rst)
    begin
        if rst = '1' or next_pc = "UUUU" then
            PC <= (others=>'0');
        elsif RISING_EDGE(clk) then
            if bubble = '1' then
                next_pc <= current_pc;
            else
                next_pc <= std_logic_vector(unsigned(current_pc) + x"0002");
            end if;
            PC <= current_pc;
        end if;
    end process;

end Behaviour;
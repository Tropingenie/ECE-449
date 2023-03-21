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
    --System Signals
    clk, rst : in std_logic;                           -- clock at twice the rate of the datapath, PC gets double clk to strobe properly
    
    --PC Register Input and Output
    PC_IN  : in std_logic_vector(15 downto 0);         -- Input value from PC register
    PC_OUT : out std_logic_vector(15 downto 0);        -- Output value to the PC register
    
    --Memory Input and Output
    M_INSTR : in std_logic_vector(15 downto 0);        -- Input from memory
    INSTR, M_ADDR : out std_logic_vector(15 downto 0); -- Instruction output and memory address issuing respectively
    
    --Branch Output Signals
    BR_INST : out std_logic_vector(6 downto 0);        -- Branch instruction opcode value
    BR_PC   : out std_logic_vector(15 downto 0)        -- Branch instruction PC value
);
end InstructionFetcher;

architecture Behaviour of InstructionFetcher is

signal old_pc, new_pc : std_logic_vector(15 downto 0);
signal branch_instr_op : std_logic_vector(6 downto 0);
signal shift_amt : integer;

begin

    INSTR <= M_INSTR;                                                 -- Just pass through. This module is only a controller
    
    
    process(clk, rst)
    begin
        
        if rst = '1' or new_pc = "UUUU" then                         -- Hande reset or uninitialized values
            old_pc <= (others=>'0');
            new_pc <= (others=>'0');
            
        elsif RISING_EDGE(clk) then                                  -- Update PC for the instruction received
            old_pc <= PC_IN;
            new_pc <= std_logic_vector(unsigned(old_pc) + x"0002"); 
    
            if M_INSTR(15) = '1' then                                -- Check for branch op in current instr on rising clock
               BR_INST <= M_INSTR(15 downto 9);
               BR_PC   <= new_pc;
            end if;
            
            PC_OUT <= new_pc;                                        -- Update the PC with the current PC value
            M_ADDR <= std_logic_vector(unsigned(new_pc) + x"0002");  -- Ask Memory for the next instruction after the new one that just came in
            
        end if; 
    end process;
end Behaviour;
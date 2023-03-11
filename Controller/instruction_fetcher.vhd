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
    clk, rst,bubble : in std_logic; -- clock at twice the rate of the datapath, PC gets double clk to strobe properly
    PC_IN  : in std_logic_vector(15 downto 0); --input value from PC register
    PC_OUT : out std_logic_vector(15 downto 0); --output value to the PC register
    INSTR, M_ADDR : out std_logic_vector(15 downto 0); -- Instruction output and memory address issuing respectively
    n_flag, z_flag : in std_logic --ALU outputs for negative and zero branches
);
end InstructionFetcher;

architecture Behaviour of InstructionFetcher is

signal current_pc, next_pc : std_logic_vector(15 downto 0);
signal branch_instr_op : std_logic_vector(6 downto 0);
signal shift_amt : integer;

begin

    INSTR <= M_INSTR; -- Just pass through. This module is only a controller
    
    
    process(clk, rst)
    begin
    
        if M_INSTR(15) = '1' then                --check for branch op in current instr
           branch_instr_op <= M_INSTR(15 downto 9); 
           end if;
        
        if rst = '1' or next_pc = "UUUU" then
            PC <= (others=>'0');
        elsif RISING_EDGE(clk) then
            current_pc <= PC_IN;
            next_pc <= std_logic_vector(unsigned(current_pc) + x"0002");
            M_ADDR <= current_pc;
           
            
            
            case branch_instr_op is --need PC saving operation
                
                
                when "UUUUUUU" | "XXXXXXX" =>
                    assert false report "Uninitialized data for branching in the instruction_fetcher.vhd module" severity note;
                when others =>
                    assert false report "Branch op not recognized in instruction_fetcher.vhd module" severity failure;
            end case;
            
        end if;
        PC_OUT <= next_pc;
    end process;

end Behaviour;
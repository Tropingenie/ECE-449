-----------------------------------------------------------
--
-- Register Arbitrator
--
-- Plug in module to arbitrate register file access. Allows
-- writing when one or fewer instructions are used, and
-- sends a "pause" signal to stop the pipeline for two
-- register instructions. In current state, Register arbitrator 
-- favours write back.
--
-- Engineer: Kai Herrero, Benjamin Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterArbitrator is
port(
    opcode_in   : in std_logic_vector(6 downto 0);  -- opcode of the "current" instruction
    opcode_back : in std_logic_vector(6 downto 0);  -- opcode of the "writing back" instruction
    AR_in       : in std_logic_vector(15 downto 0); -- Arithmetic result (data) from the "wiring back" instruction
    ra          : in std_logic_vector(2 downto 0);  -- writeback register of the "writing back" instruction
    --rd_2        : in std_logic_vector(2 downto 0);  -- Second register from "current" instruction [UNUSED]
    clk         : in std_logic;                     -- Clock at twice the rate of the datapath
    AR_out      : out std_logic_vector(15 downto 0);-- Output numeric result of the data
    wr_en       : out std_logic;                    -- Write enable for writeback
    r_sel       : out std_logic_vector(2 downto 0)  -- Selected register

);
end RegisterArbitrator;

architecture Behavioral of RegisterArbitrator is

--SIGNAL DECLARATIONS HERE--
--COMPONENT DECLARATIONS HERE--

begin

    process(clk)
    begin

     case opcode_back is
     
--case 1 : "Writeback, current op is paused" OP_BACK IS A1 FORMAT                
        when "0000001" =>       --ADD OP
            AR_out <= AR_in;
            r_sel <= ra;
            wr_en <= '1';
                   
        when "0000010" =>       --SUB OP
            AR_out <= AR_in;
            r_sel <= ra;
            wr_en <= '1';
                   
        when "0000011" =>       --MULT Op 
            AR_out <= AR_in;
            r_sel <= ra;
            wr_en <= '1';
            
        when "0000100" =>       --NAND Op
            AR_out <= AR_in;
            r_sel <= ra;
            wr_en <= '1';
            
--case 2 : "Write forward, writeback is paused" OP_BACK IS NOT A1 FORMAT 
        when others =>
            wr_en <= '0';
            r_sel <= opcode_in(8 downto 6);
            assert false report "Opcode is not a writeback" severity note;
                                   
    end case;            
    
    
    

    end process;
end Behavioral;